//
// Copyright (C) 2005-2021 Alfresco Software Limited.
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
import MaterialComponents.MaterialDialogs

class OfflineViewModel: PageFetchingViewModel {
    var supportedNodeTypes: [NodeType] = []
    var coordinatorServices: CoordinatorServices?
    private var shouldEnableListButton = true

    // MARK: - Init

    required init(with coordinatorServices: CoordinatorServices?, listRequest: SearchRequest?) {
        super.init()
        self.coordinatorServices = coordinatorServices
        refreshList()
    }

    // MARK: - PageFetchingViewModel

    override func fetchItems(with requestPagination: RequestPagination,
                             userInfo: Any?,
                             completionHandler: @escaping PagedResponseCompletionHandler) {
        refreshList()
    }

    override func handlePage(results: [ListNode], pagination: Pagination?, error: Error?) {
        updateResults(results: results, pagination: pagination, error: error)
    }

    override func updatedResults(results: [ListNode], pagination: Pagination) {
        pageUpdatingDelegate?.didUpdateList(error: nil,
                                            pagination: pagination)
    }

    // MARK: - Private interface

    func offlineMarkedNodes() -> [ListNode] {
        let listNodeDataAccessor = ListNodeDataAccessor()
        return listNodeDataAccessor.queryMarkedOffline()
    }

    private func showOverrideSyncOnCellularDataDialog() {
        let title = LocalizationConstants.Dialog.overrideSyncCellularDataTitle
        let message = LocalizationConstants.Dialog.overrideSyncCellularDataMessage

        let confirmAction = MDCAlertAction(title: LocalizationConstants.General.yes) { [weak self] _ in
            guard let sSelf = self else { return }
            UserProfile.allowOnceSyncOverCellularData = true
            let syncTriggersService = sSelf.coordinatorServices?.syncTriggersService
            syncTriggersService?.triggerSync(for: .userDidInitiateSync)
        }
        confirmAction.accessibilityIdentifier = "confirmActionButton"

        let cancelAction = MDCAlertAction(title: LocalizationConstants.General.later)
        cancelAction.accessibilityIdentifier = "cancelActionButton"

        DispatchQueue.main.async {
            if let presentationContext = UIViewController.applicationTopMostPresented {
                _ = presentationContext.showDialog(title: title,
                                                   message: message,
                                                   actions: [confirmAction, cancelAction],
                                                   completionHandler: {})
            }
        }
    }
}

// MARK: - ListViewModelProtocol

extension OfflineViewModel: ListViewModelProtocol {
    func isEmpty() -> Bool {
        return results.isEmpty
    }

    func emptyList() -> EmptyListProtocol {
        return EmptyOffline()
    }

    func numberOfSections() -> Int {
        return (results.isEmpty) ? 0 : 1
    }

    func numberOfItems(in section: Int) -> Int {
        return results.count
    }

    func refreshList() {
        results = offlineMarkedNodes()
        handlePage(results: results,
                   pagination: nil,
                   error: nil)
    }

    func listActionTitle() -> String? {
        return LocalizationConstants.Buttons.syncAll
    }

    func listNode(for indexPath: IndexPath) -> ListNode {
        return results[indexPath.row]
    }

    func shouldDisplaySettingsButton() -> Bool {
        return true
    }

    func shouldDisplayListActionButton() -> Bool {
        return true
    }

    func shouldEnableListActionButton() -> Bool {
        return shouldEnableListButton
    }

    func shouldPreview(node: ListNode) -> Bool {
        let listNodeDataAccessor = ListNodeDataAccessor()

        if node.isAFolderType() {
            return true
        }
        if listNodeDataAccessor.isContentDownloaded(for: node) {
            return true
        }
        return false
    }

    func shouldDisplayPullToRefreshOffline() -> Bool {
        true
    }

    func performListAction() {
        let connectivityService = coordinatorServices?.connectivityService
        if connectivityService?.status == .cellular &&
            UserProfile.allowSyncOverCellularData == false {
            showOverrideSyncOnCellularDataDialog()
        } else {
            let syncTriggersService = coordinatorServices?.syncTriggersService
            syncTriggersService?.triggerSync(for: .userDidInitiateSync)
        }
    }

    func syncStatus(for node: ListNode) -> ListEntrySyncStatus {
        if node.isAFileType() {
            let nodeSyncStatus = node.hasSyncStatus()
            var entryListStatus: ListEntrySyncStatus

            switch nodeSyncStatus {
            case .pending:
                entryListStatus = .pending
            case .error:
                entryListStatus = .error
            case .inProgress:
                entryListStatus = .inProgress
            case .synced:
                entryListStatus = .synced
            default:
                entryListStatus = .undefined
            }

            return entryListStatus
        }

        return .undefined
    }
}

// MARK: - SyncServiceDelegate

extension OfflineViewModel: SyncServiceDelegate {
    func syncDidStarted() {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.shouldEnableListButton = false
            sSelf.pageUpdatingDelegate?.didUpdateListActionState(enable: false)
        }
    }

    func syncDidFinished() {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.refreshList()
            sSelf.shouldEnableListButton = true
            sSelf.pageUpdatingDelegate?.didUpdateListActionState(enable: true)
        }
    }
}

// MARK: - Event observable

extension OfflineViewModel: EventObservable {
    func handle(event: BaseNodeEvent, on queue: EventQueueType) {
        if let publishedEvent = event as? FavouriteEvent {
            handleFavorite(event: publishedEvent)
        } else if let publishedEvent = event as? MoveEvent {
            handleMove(event: publishedEvent)
        } else if let publishedEvent = event as? OfflineEvent {
            handleOffline(event: publishedEvent)
        } else if let publishedEvent = event as? SyncStatusEvent {
            handleSyncStatus(event: publishedEvent)
        }
    }

    private func handleFavorite(event: FavouriteEvent) {
        let eventNode = event.node
        for listNode in results where listNode == eventNode {
            listNode.favorite = eventNode.favorite
        }
    }

    private func handleMove(event: MoveEvent) {
        let eventNode = event.node
        switch event.eventType {
        case .moveToTrash:
            if eventNode.nodeType == .file {
                if let indexOfMovedNode = results.firstIndex(of: eventNode) {
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
        let eventNode = event.node
        switch event.eventType {
        case .marked:
            refreshList()
        case .removed:
            if let indexOfNode = results.firstIndex(of: eventNode) {
                results.remove(at: indexOfNode)
            }
        }
    }

    private func handleSyncStatus(event: SyncStatusEvent) {
        let eventNode = event.node
        if let indexOfNode = results.firstIndex(of: eventNode) {
            results[indexOfNode] = eventNode
        }
    }
}
