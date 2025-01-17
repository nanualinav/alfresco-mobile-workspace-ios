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

typealias TopLevelBrowseDataSource = (topLevelBrowseViewModel: ListViewModelProtocol,
                                     resultsViewModel: ResultsViewModel,
                                     globalSearchViewModel: SearchViewModelProtocol)

class TopLevelBrowseViewModelFactory {
    var coordinatorServices: CoordinatorServices?

    func topLevelBrowseDataSource(browseNode: BrowseNode) -> TopLevelBrowseDataSource {
        let topLevelBrowseViewModel = listViewModel(from: browseNode.type)
        let resultsViewModel = self.resultsViewModel()
        let globalSearchViewModel = self.globalSearchViewModel(from: browseNode.type,
                                                               with: browseNode.title,
                                                               with: resultsViewModel)

        return (topLevelBrowseViewModel, resultsViewModel, globalSearchViewModel)
    }

    func listViewModel(from type: BrowseType?) -> ListViewModelProtocol {
        switch type {
        case .personalFiles:
            return personalFilesViewModel()
        case .myLibraries:
            return myLibrariesViewModel()
        case .shared:
            return sharedViewModel()
        case .trash:
            return trashViewModel()
        default:
            return defaultViewModel()
        }
    }

    func globalSearchViewModel(from type: BrowseType?,
                               with title: String?,
                               with resultViewModel: ResultsViewModel) -> SearchViewModelProtocol {
        let accountService = coordinatorServices?.accountService
        var searchChip: SearchChipItem?

        switch type {
        case .personalFiles:
            if let nodeID = UserProfile.personalFilesID {
                searchChip = SearchChipItem(name: LocalizationConstants.Search.searchIn + (title ?? ""),
                                            type: .node,
                                            selected: true,
                                            nodeID: nodeID)
            } else {
                ProfileService.featchPersonalFilesID()
            }
        default:
            let globalSearchViewModel = GlobalSearchViewModel(accountService: accountService)
            resultViewModel.delegate = globalSearchViewModel
            globalSearchViewModel.delegate = resultViewModel
            globalSearchViewModel.displaySearchBar = false
            globalSearchViewModel.displaySearchButton = false
            return globalSearchViewModel
        }

        let contextualSearchViewModel = ContextualSearchViewModel(accountService: accountService)

        contextualSearchViewModel.searchChipNode = searchChip
        resultViewModel.delegate = contextualSearchViewModel
        contextualSearchViewModel.delegate = resultViewModel
        return contextualSearchViewModel
    }

    func resultsViewModel() -> ResultsViewModel {
        let eventBusService = coordinatorServices?.eventBusService

        let resultViewModel = ResultsViewModel(with: coordinatorServices)
        eventBusService?.register(observer: resultViewModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: resultViewModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: resultViewModel,
                                  for: OfflineEvent.self,
                                  nodeTypes: [.file, .folder])

        return resultViewModel
    }

    // MARK: - Private builders

    private func personalFilesViewModel() -> ListViewModelProtocol {
        let eventBusService = coordinatorServices?.eventBusService

        let viewModel = FolderDrillViewModel(with: coordinatorServices,
                                             listRequest: nil)
        eventBusService?.register(observer: viewModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file, .folder])
        eventBusService?.register(observer: viewModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder])
        eventBusService?.register(observer: viewModel,
                                  for: OfflineEvent.self,
                                  nodeTypes: [.file, .folder])
        return viewModel
    }

    private func myLibrariesViewModel() -> ListViewModelProtocol {
        let eventBusService = coordinatorServices?.eventBusService

        let viewModel = MyLibrariesViewModel(with: coordinatorServices,
                                             listRequest: nil)
        eventBusService?.register(observer: viewModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.site])
        eventBusService?.register(observer: viewModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.site])
        return viewModel
    }

    private func sharedViewModel() -> ListViewModelProtocol {
        let eventBusService = coordinatorServices?.eventBusService

        let viewModel = SharedViewModel(with: coordinatorServices,
                                        listRequest: nil)
        eventBusService?.register(observer: viewModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file])
        eventBusService?.register(observer: viewModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: viewModel,
                                  for: OfflineEvent.self,
                                  nodeTypes: [.file, .folder])
        return viewModel
    }

    private func trashViewModel() -> ListViewModelProtocol {
        let eventBusService = coordinatorServices?.eventBusService

        let viewModel = TrashViewModel(with: coordinatorServices,
                              listRequest: nil)
        eventBusService?.register(observer: viewModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        return viewModel
    }

    private func defaultViewModel() -> ListViewModelProtocol {
        let eventBusService = coordinatorServices?.eventBusService

        let viewModel = FolderDrillViewModel(with: coordinatorServices,
                                             listRequest: nil)
        eventBusService?.register(observer: viewModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file, .folder])
        eventBusService?.register(observer: viewModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: viewModel,
                                  for: OfflineEvent.self,
                                  nodeTypes: [.file, .folder])
        return viewModel
    }
}
