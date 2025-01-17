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
import MaterialComponents.MaterialContainerScheme

struct CameraConfigurationLayout {
    var onSurfaceColor: UIColor
    var onSurface60Color: UIColor
    var onSurface5Color: UIColor
    var surfaceColor: UIColor
    var surface60Color: UIColor
    var primaryColor: UIColor
    var videoShutterColor: UIColor
    
    var subtitle2Font: UIFont
    var headline6Font: UIFont
    
    var textFieldScheme: MDCContainerScheming
    let buttonScheme: MDCContainerScheming
    
    var autoFlashText: String
    var onFlashText: String
    var offFlashText: String
}

struct CameraLocalization {
    var sliderPhoto: String
    var saveButton: String
    var previewScreenTitle: String
    var fileNameTextField: String
    var descriptionTextField: String
    var errorNodeNameSpecialCharacters: String
}
