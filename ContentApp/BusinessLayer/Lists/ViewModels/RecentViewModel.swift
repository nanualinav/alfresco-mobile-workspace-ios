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
import UIKit
import AlfrescoAuth
import AlfrescoContent

class RecentViewModel: PageFetchingViewModel, ListViewModelProtocol, EventObservable {
    var listRequest: SearchRequest?
    var groupedLists: [GroupedList] = []
    var coordinatorServices: CoordinatorServices?
    var supportedNodeTypes: [NodeType] = []

    // MARK: - Init

    required init(with coordinatorServices: CoordinatorServices?, listRequest: SearchRequest?) {
        self.coordinatorServices = coordinatorServices
        self.listRequest = listRequest
    }

    // MARK: - ListViewModelProtocol

    func isEmpty() -> Bool {
        return groupedLists.isEmpty
    }

    func emptyList() -> EmptyListProtocol {
        return EmptyRecents()
    }

    func numberOfSections() -> Int {
        return groupedLists.count
    }

    func numberOfItems(in section: Int) -> Int {
        return groupedLists[section].list.count
    }

    func refreshList() {
        refreshedList = true
        currentPage = 1
        recentsList(with: nil)
    }

    func listNode(for indexPath: IndexPath) -> ListNode {
        return groupedLists[indexPath.section].list[indexPath.row]
    }

    func titleForSectionHeader(at indexPath: IndexPath) -> String {
        return groupedLists[indexPath.section].titleGroup
    }

    func shouldDisplaySections() -> Bool {
        return true
    }

    func shouldDisplayListLoadingIndicator() -> Bool {
        return self.shouldDisplayNextPageLoadingIndicator
    }

    func shouldDisplaySettingsButton() -> Bool {
        return true
    }

    override func updatedResults(results: [ListNode], pagination: Pagination) {
        groupedLists = []
        addInGroupList(self.results)
        pageUpdatingDelegate?.didUpdateList(error: nil,
                                            pagination: pagination)
    }

    override func fetchItems(with requestPagination: RequestPagination, userInfo: Any?, completionHandler: @escaping PagedResponseCompletionHandler) {
        recentsList(with: requestPagination)
    }

    override func handlePage(results: [ListNode], pagination: Pagination?, error: Error?) {
        updateResults(results: results, pagination: pagination, error: error)
    }

    func performListAction() {
        // Do nothing
    }

    // MARK: - Public methods

    func recentsList(with paginationRequest: RequestPagination?) {
        pageFetchingGroup.enter()
        let accountService = coordinatorServices?.accountService
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            let recentFilesRequest = SearchRequestBuilder.recentFilesRequest(pagination: paginationRequest)
            SearchAPI.recentFiles(recentFilesRequest: recentFilesRequest) { (result, error) in
                var listNodes: [ListNode] = []
                if let entries = result?.list?.entries {
                    listNodes = ResultsNodeMapper.map(entries)
                } else {
                    if let error = error {
                        AlfrescoLog.error(error)
                    }
                }
                let paginatedResponse = PaginatedResponse(results: listNodes,
                                                          error: error,
                                                          requestPagination: paginationRequest,
                                                          responsePagination: result?.list?.pagination)
                sSelf.handlePaginatedResponse(response: paginatedResponse)
            }
        })
    }

    // MARK: - Private methods

    private func add(element: ListNode, inGroupType type: GroupedListType) {
        for groupedList in groupedLists where groupedList.type == type {
            groupedList.list.append(element)
            return
        }
        groupedLists.append(GroupedList(type: type, list: [element]))
    }

    private func addInGroupList(_ results: [ListNode]) {
        for element in results {
            if let date = element.modifiedAt {
                var groupType: GroupedListType = .today
                if date.isInToday {
                    groupType = .today
                } else if date.isInYesterday {
                    groupType = .yesterday
                } else if date.isInThisWeek {
                    groupType = .thisWeek
                } else if date.isInLastWeek {
                    groupType = .lastWeek
                } else {
                    groupType = .older
                }
                self.add(element: element, inGroupType: groupType)
            } else {
                groupedLists.first?.list.append(element)
            }
        }
    }
}

// MARK: - Event observable

extension RecentViewModel {

    func handle(event: BaseNodeEvent, on queue: EventQueueType) {
        if let publishedEvent = event as? FavouriteEvent {
            handleFavorite(event: publishedEvent)
        } else if let publishedEvent = event as? MoveEvent {
            handleMove(event: publishedEvent)
        } else if let publishedEvent = event as? OfflineEvent {
            handleOffline(event: publishedEvent)
        }
    }

    private func handleFavorite(event: FavouriteEvent) {
        let node = event.node
        for listNode in results where listNode == node {
            listNode.favorite = node.favorite
        }
    }

    private func handleMove(event: MoveEvent) {
        let node = event.node
        switch event.eventType {
        case .moveToTrash:
            if node.nodeType == .file {
                if let indexOfMovedNode = results.firstIndex(of: node) {
                    results.remove(at: indexOfMovedNode)
                }
            } else {
                refreshList()
            }
        case .restore:
            refreshList()
        default: break
        }
    }

    private func handleOffline(event: OfflineEvent) {
        let node = event.node
        if let indexOfOfflineNode = results.firstIndex(of: node) {
            let listNode = results[indexOfOfflineNode]
            listNode.update(with: node)
            results[indexOfOfflineNode] = listNode
        }
    }
}
