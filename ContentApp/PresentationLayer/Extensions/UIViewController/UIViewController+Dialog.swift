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
import MaterialComponents.MaterialDialogs
import MaterialComponents.MDCAlertController_ButtonForAction

extension UIViewController {
    func showDialog(title: String?,
                    message: String?,
                    actions: [MDCAlertAction] = [],
                    accesoryView: UIView? = nil,
                    completionHandler: @escaping () -> Void) -> MDCAlertController {
        let alertController = MDCAlertController(title: title,
                                                 message: message)

        alertController.mdc_dialogPresentationController?.dismissOnBackgroundTap = false

        for action in actions {
            alertController.addAction(action)
        }

        if let accesoryView = accesoryView {
            alertController.accessoryView = accesoryView
        }

        if let themingService =
            ApplicationBootstrap.shared().repository.service(of: MaterialDesignThemingService.identifier) as? MaterialDesignThemingService, let currentTheme = themingService.activeTheme {

            alertController.applyTheme(withScheme: themingService.containerScheming(for: .pdfPasswordDialog))
            alertController.titleFont = currentTheme.subtitle1TextStyle.font
            alertController.titleColor = currentTheme.onSurfaceColor
            alertController.messageFont = currentTheme.body2TextStyle.font
            alertController.messageColor = currentTheme.onSurface60Color
            alertController.view.backgroundColor = currentTheme.surfaceColor
            alertController.cornerRadius = UIConstants.cornerRadiusDialog

            for action in alertController.actions {
                let button = alertController.button(for: action)
                button?.isUppercaseTitle = false
                button?.applyTextTheme(withScheme: themingService.containerScheming(for: .dialogButton))
            }
        }

        self.present(alertController, animated: true, completion: completionHandler)

        return alertController
    }
}
