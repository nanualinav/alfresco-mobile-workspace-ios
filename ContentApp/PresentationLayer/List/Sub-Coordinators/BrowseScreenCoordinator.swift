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

protocol BrowseScreenCoordinatorDelegate: class {
    func showTopLevelFolderScreen(from browseNode: BrowseNode)
}

class BrowseScreenCoordinator: PresentingCoordinator,
                               ListCoordinatorProtocol {
    private let presenter: TabBarMainViewController
    private var browseViewController: BrowseViewController?
    private var navigationViewController: UINavigationController?
    private var browseTopLevelFolderScreenCoordinator: BrowseTopLevelFolderScreenCoordinator?
    private var actionMenuCoordinator: ActionMenuScreenCoordinator?

    init(with presenter: TabBarMainViewController) {
        self.presenter = presenter
    }

    override func start() {
        let viewModelFactory = BrowseViewModelFactory()
        viewModelFactory.coordinatorServices = coordinatorServices

        let browseDataSource = viewModelFactory.browseDataSource()

        let viewController = BrowseViewController.instantiateViewController()
        viewController.title = LocalizationConstants.ScreenTitles.browse
        viewController.coordinatorServices = coordinatorServices
        viewController.listItemActionDelegate = self
        viewController.browseScreenCoordinatorDelegate = self
        viewController.tabBarScreenDelegate = presenter
        viewController.listViewModel = browseDataSource.browseViewModel
        viewController.searchViewModel = browseDataSource.globalSearchViewModel
        viewController.resultViewModel = browseDataSource.resultsViewModel

        let navigationViewController = UINavigationController(rootViewController: viewController)
        self.presenter.viewControllers?.append(navigationViewController)
        self.navigationViewController = navigationViewController
        browseViewController = viewController
    }

    func scrollToTopOrPopToRoot() {
        navigationViewController?.popToRootViewController(animated: true)
        browseViewController?.cancelSearchMode()
    }
}

extension BrowseScreenCoordinator: BrowseScreenCoordinatorDelegate {
    func showTopLevelFolderScreen(from browseNode: BrowseNode) {
        if let navigationViewController = self.navigationViewController {
            let staticFolderScreenCoordinator =
                BrowseTopLevelFolderScreenCoordinator(with: navigationViewController,
                                                      browseNode: browseNode)
            staticFolderScreenCoordinator.start()
            self.browseTopLevelFolderScreenCoordinator = staticFolderScreenCoordinator
        }
    }
}

extension BrowseScreenCoordinator: ListItemActionDelegate {
    func showPreview(for node: ListNode,
                     from dataSource: ListComponentDataSourceProtocol) {
        if let navigationViewController = self.navigationViewController {
            if node.isAFolderType() || node.nodeType == .site {
                startFolderCoordinator(for: node,
                                       presenter: navigationViewController)
            } else if node.isAFileType() {
                startFileCoordinator(for: node,
                                     presenter: navigationViewController)
            } else {
                AlfrescoLog.error("Unable to show preview for unknown node type")
            }
        }
    }

    func showActionSheetForListItem(for node: ListNode,
                                    from dataSource: ListComponentDataSourceProtocol,
                                    delegate: NodeActionsViewModelDelegate) {
        if let navigationViewController = self.navigationViewController {
            let actionMenuViewModel = ActionMenuViewModel(node: node,
                                                          coordinatorServices: coordinatorServices)

            let nodeActionsModel = NodeActionsViewModel(node: node,
                                                        delegate: delegate,
                                                        coordinatorServices: coordinatorServices)
            let coordinator = ActionMenuScreenCoordinator(with: navigationViewController,
                                                          actionMenuViewModel: actionMenuViewModel,
                                                          nodeActionViewModel: nodeActionsModel)
            coordinator.start()
            actionMenuCoordinator = coordinator
        }
    }
}
