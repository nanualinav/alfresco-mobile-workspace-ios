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

import UIKit
import AlfrescoContent

protocol ActionMenuViewModelDelegate: class {
    func finishProvideActions()
}

class ActionMenuViewModel {
    private var listNode: ListNode?
    private var toolbarActions: [ActionMenu]?
    private var menuActions: [[ActionMenu]]
    private var excludedActions: [ActionMenuType]
    private var coordinatorServices: CoordinatorServices?
    private let nodeOperations: NodeOperations

    weak var delegate: ActionMenuViewModelDelegate?

    // MARK: - Init

    init(menuActions: [[ActionMenu]] = [[ActionMenu]](),
         node: ListNode? = nil,
         coordinatorServices: CoordinatorServices?,
         excludedActionTypes: [ActionMenuType] = []) {

        self.listNode = node
        self.menuActions = menuActions
        self.coordinatorServices = coordinatorServices
        self.nodeOperations = NodeOperations(accountService: coordinatorServices?.accountService)
        self.excludedActions = excludedActionTypes

        if let listNode = listNode {
            self.menuActions = [[ActionMenu(title: listNode.title,
                                            type: .node,
                                            icon: FileIcon.icon(for: listNode))],
                                [ActionMenu(title: "", type: .placeholder),
                                 ActionMenu(title: "", type: .placeholder)]]
        }
    }

    // MARK: - Public Helpers

    func fetchNodeInformation() {
        guard let listNode = self.listNode else {
            delegate?.finishProvideActions()
            return
        }
        if listNode.shouldUpdate() == false {
            createMenuActions()
            return
        }
        if listNode.nodeType == .site {
            nodeOperations.fetchNodeIsFavorite(for: listNode.guid) { [weak self] (_, error) in
                guard let sSelf = self else { return }
                if error == nil {
                    sSelf.listNode?.favorite = true
                }
                sSelf.createMenuActions()
            }
        } else {
            nodeOperations.fetchNodeDetails(for: listNode.guid) { [weak self] (result, _) in
                guard let sSelf = self else { return }
                if let entry = result?.entry {
                    sSelf.listNode?.update(with: NodeChildMapper.create(from: entry))
                }
                sSelf.createMenuActions()
            }
        }
    }

    func actions() -> [[ActionMenu]] {
        return menuActions
    }

    func actionsForToolbar() -> [ActionMenu]? {
        return toolbarActions
    }

    func indexInToolbar(for actionType: ActionMenuType) -> Int? {
        guard let actions = toolbarActions else { return nil }
        for index in 0...actions.count - 1 where actions[index].type == actionType {
            return index
        }
        return nil
    }

    func numberOfActions() -> CGFloat {
        var numberOfActions = 0
        for section in menuActions {
            numberOfActions += section.count
        }
        return CGFloat(numberOfActions)
    }

    func shouldShowSectionSeparator(for indexPath: IndexPath) -> Bool {
        if menuActions[indexPath.section][indexPath.row].type == .node {
            return false
        }
        if indexPath.section != menuActions.count - 1 &&
            indexPath.row == menuActions[indexPath.section].count - 1 {
            return true
        }
        return false
    }

    // MARK: - Private Helpers

    private func createMenuActions() {
        guard let listNode = listNode else { return }
        if listNode.trashed == true {
            menuActions = ActionsMenuTrashMoreButton.actions(for: listNode)
        } else {
            menuActions = ActionsMenuGeneric.actions(for: listNode)

            for (index, var actionMenuGroup) in menuActions.enumerated() {
                actionMenuGroup.removeAll { actionMenu -> Bool in
                    return excludedActions.contains(actionMenu.type)
                }
                menuActions[index] = actionMenuGroup
            }
        }

        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.delegate?.finishProvideActions()
        }
    }
}
