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

struct ActionMenu {
    var title: String
    var type: ActionMenuType
    var icon: UIImage

    init(title: String, type: ActionMenuType, icon: UIImage? = nil) {
        self.title = title
        self.type = type
        if let icon = icon {
            self.icon = icon
        } else {
            self.icon = UIImage(named: self.type.rawValue) ?? UIImage()
        }
    }
}

enum ActionMenuType: String {
    case addFavorite = "ic-action-outline-favorite"
    case removeFavorite = "ic-action-fill-favorite"
    case delete = "ic-action-delete"
    case node = "ic-node"
}