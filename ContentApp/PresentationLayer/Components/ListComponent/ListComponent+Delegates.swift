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

import UIKit
import AlfrescoContent

protocol ListItemActionDelegate: class {
    func showPreview(for node: ListNode,
                     from dataSource: ListComponentDataSourceProtocol)
    func showActionSheetForListItem(for node: ListNode,
                                    from dataSource: ListComponentDataSourceProtocol,
                                    delegate: NodeActionsViewModelDelegate)
    func showNodeCreationSheet(delegate: NodeActionsViewModelDelegate)
    func showNodeCreationDialog(with actionMenu: ActionMenu,
                                delegate: CreateNodeViewModelDelegate?)
    func showCamera()
}

protocol ListComponentActionDelegate: class {
    func elementTapped(node: ListNode)
    func didUpdateList(in listComponentViewController: ListComponentViewController,
                       error: Error?,
                       pagination: Pagination?)
    func fetchNextListPage(in listComponentViewController: ListComponentViewController,
                           for itemAtIndexPath: IndexPath)
    func performListAction()
}

protocol ListComponentPageUpdatingDelegate: class {
    func didUpdateList(error: Error?,
                       pagination: Pagination?)
    func shouldDisplayCreateButton(enable: Bool)
    func didUpdateListActionState(enable: Bool)
}

extension ListItemActionDelegate {
    func showNodeCreationSheet(delegate: NodeActionsViewModelDelegate) {
        // Do nothing
    }

    func showNodeCreationDialog(with actionMenu: ActionMenu,
                                delegate: CreateNodeViewModelDelegate?) {
        // Do nothing
    }
    
    func showCamera() {
        // Do nothing
    }
}
