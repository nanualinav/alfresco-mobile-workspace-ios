//
// Copyright (C) 2005-2020 Alfresco Software Limited.
//
// This file is part of the Alfresco Content Mobile iOS App.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import AlfrescoContent

class GlobalSearchViewModel: PageFetchingViewModel, SearchViewModelProtocol {
    var accountService: AccountService?
    var searchChips: [SearchChipItem] = []

    weak var delegate: SearchViewModelDelegate?
    var displaySearchBar = true
    var displaySearchButton = false

    private var liveSearchTimer: Timer?
    private let searchTimerBuffer = 0.7
    var lastSearchedString: String?

    // MARK: - Init

    init(accountService: AccountService?) {
        super.init()
        self.accountService = accountService
    }

    // MARK: - Public methods

    func shouldDisplaySearchBar() -> Bool {
        return displaySearchBar
    }

    func shouldDisplaySearchButton() -> Bool {
        return displaySearchButton
    }

    func defaultSearchChips() -> [SearchChipItem] {
        searchChips = [ SearchChipItem(name: LocalizationConstants.Search.filterFiles, type: .file),
                        SearchChipItem(name: LocalizationConstants.Search.filterFolders, type: .folder),
                        SearchChipItem(name: LocalizationConstants.Search.filterLibraries, type: .library, selected: false)]
        return searchChips
    }

    func searchChipTapped(tappedChip: SearchChipItem) -> [Int] {
        var indexChipsReload: [Int] = []
        if tappedChip.type == .library {
            for chip in searchChips where chip.type != .library && chip.selected {
                chip.selected = false
                indexChipsReload.append(searchChips.firstIndex(where: { $0 == chip }) ?? 0)
            }
        } else {
            for chip in searchChips where chip.type == .library && chip.selected {
                chip.selected = false
                indexChipsReload.append(searchChips.firstIndex(where: { $0 == chip }) ?? 0)
            }
        }
        return indexChipsReload
    }

    func performSearch(for string: String?, paginationRequest: RequestPagination?) {
        lastSearchedString = string
        if paginationRequest == nil {
            currentPage = 1
            results = []
        }

        liveSearchTimer?.invalidate()
        guard let searchString = string?.trimmingCharacters(in: .whitespacesAndNewlines),
              !searchString.isEmpty else {
            self.delegate?.handle(results: [])
            return
        }

        pageFetchingGroup.enter()
        if isSearchForLibraries() {
            performLibrariesSearch(searchString: searchString, paginationRequest: paginationRequest)
        } else {
            performFileFolderSearch(searchString: searchString, paginationRequest: paginationRequest)
        }
    }

    func performLiveSearch(for string: String?) {
        liveSearchTimer?.invalidate()
        guard let searchString = string, searchString.canPerformLiveSearch() else {
            self.delegate?.handle(results: [])
            return
        }
        liveSearchTimer = Timer.scheduledTimer(withTimeInterval: searchTimerBuffer, repeats: false, block: { [weak self] (timer) in
            timer.invalidate()
            guard let sSelf = self else { return }
            sSelf.performSearch(for: searchString)
        })
    }

    func fetchNextSearchResultsPage(for string: String?, index: IndexPath) {
        fetchNextListPage(index: index, userInfo: string ?? "")
    }

    override func fetchItems(with requestPagination: RequestPagination, userInfo: Any?, completionHandler: @escaping PagedResponseCompletionHandler) {
        if let searchTerm = userInfo as? String {
            self.performSearch(for: searchTerm, paginationRequest: requestPagination)
        }
    }

    override func handlePage(results: [ListNode], pagination: Pagination?, error: Error?) {
        updateResults(results: results, pagination: pagination, error: error)
        self.delegate?.handle(results: results, pagination: pagination, error: error)
    }

    // MARK: Private Methods

    private func isSearchForLibraries() -> Bool {
        for chip in searchChips where chip.type == .library {
            return chip.selected
        }
        return false
    }

    private func performLibrariesSearch(searchString: String, paginationRequest: RequestPagination?) {
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            let searchChipsState = sSelf.searchChipsState()
            QueriesAPI.findSites(term: searchString, skipCount: paginationRequest?.skipCount, maxItems: paginationRequest?.maxItems ?? APIConstants.pageSize) { (results, error) in

                var listNodes: [ListNode] = []
                if let entries = results?.list.entries {
                    listNodes = SitesNodeMapper.map(entries)
                }

                let paginatedResponse = PaginatedResponse(results: listNodes,
                                                          error: error,
                                                          requestPagination: paginationRequest,
                                                          responsePagination: results?.list.pagination)

                if sSelf.changedSearchChipsState(with: searchChipsState) == false {
                    sSelf.handlePaginatedResponse(response: paginatedResponse)
                } else {
                    sSelf.pageFetchingGroup.leave()
                }
            }
        })
    }

    private func performFileFolderSearch(searchString: String, paginationRequest: RequestPagination?) {
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            let searchChipsState = sSelf.searchChipsState()
            let simpleSearchRequest = SearchRequestBuilder.searchRequest(searchString,
                                                                         chipFilters: sSelf.searchChips,
                                                                         pagination: paginationRequest)
            SearchAPI.simpleSearch(searchRequest: simpleSearchRequest) { (result, error) in

                var listNodes: [ListNode] = []
                if let entries = result?.list?.entries {
                    listNodes = ResultsNodeMapper.map(entries)
                }

                let paginatedResponse = PaginatedResponse(results: listNodes,
                                                          error: error,
                                                          requestPagination: paginationRequest,
                                                          responsePagination: result?.list?.pagination)

                if sSelf.changedSearchChipsState(with: searchChipsState) == false {
                    sSelf.handlePaginatedResponse(response: paginatedResponse)
                } else {
                    sSelf.pageFetchingGroup.leave()
                }
            }
        })
    }

    private func searchChipsState() -> String {
        var state = ""
        for chip in searchChips where chip.selected == true {
            state += chip.type.rawValue
        }
        return state
    }

    private func changedSearchChipsState(with oldState: String) -> Bool {
        // Mixed items displayed in search results list when server is responding slow and user changes the filter
        let state = self.searchChipsState()
        if oldState == state {
            return false
        }
        return true
    }
}

extension GlobalSearchViewModel: ResultsViewModelDelegate {
    func refreshResults() {
        performSearch(for: lastSearchedString, paginationRequest: nil)
    }

    func isNodePathEnabled() -> Bool {
        for chip in searchChips where chip.selected && chip.type == .library {
            return false
        }

        return true
    }
}
