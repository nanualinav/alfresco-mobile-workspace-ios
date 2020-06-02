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

protocol PresentationTheme {

    // TYPOGRAPHY - LOGIN COMPONENTS
    /// Buttons
    var loginButtonFont: UIFont { get }
    var loginUtilitiesButtonFont: UIFont { get }
    var loginSavePadButtonFont: UIFont { get }
    /// Labels
    var productLabelFont: UIFont { get }
    var applicationTitleFont: UIFont { get }
    var loginCopyrightLabelFont: UIFont { get }
    var loginFieldLabelFont: UIFont { get }
    var loginHTTPSLabelFont: UIFont { get }
    var loginTitleLabelFont: UIFont { get }
    var loginInfoLabelFont: UIFont { get }
    var loginInfoHostnameLabelFont: UIFont { get }
    var needHelpTitleLabelFont: UIFont { get }
    /// TextFields
    var loginTextFieldFont: UIFont { get }
    /// Textviews
    var needHelpHintTextViewFont: UIFont { get }

    // COLORS - LOGIN COMPONENTS
    /// Buttons
    var loginButtonColor: UIColor { get }
    var loginNeedHelpButtonColor: UIColor { get }
    var loginAdvancedSettingsButtonColor: UIColor { get }
    var loginSavePadButtonColor: UIColor { get }
    /// Labels
    var productLabelColor: UIColor { get }
    var applicationTitleColor: UIColor { get }
    var loginCopyrightLabelColor: UIColor { get }
    var loginFieldLabelColor: UIColor { get }
    var loginInfoLabelColor: UIColor { get }
    var loginFieldDisableLabelColor: UIColor { get }
    var loginTitleLabelColor: UIColor { get }
    var needHelpTitleColor: UIColor { get }
    /// TextFields
    var loginTextFieldPrimaryColor: UIColor { get }
    var loginTextFieldErrorColor: UIColor { get }
    var loginTextFieldOnSurfaceColor: UIColor { get }
    var loginTextFieldIconColor: UIColor { get }
    /// Textviews
    var needHelpHintTextViewColor: UIColor { get }
}

struct DefaultTheme: PresentationTheme {
    // MARK: - TYPOGRAPHY - LOGIN COMPONENTS
    /// Buttons
    var loginButtonFont = UIFont.systemFont(ofSize: 22)
    var loginUtilitiesButtonFont = UIFont.systemFont(ofSize: 14)
    var loginSavePadButtonFont = UIFont.systemFont(ofSize: 17)
    /// Labels
    var productLabelFont = UIFont.systemFont(ofSize: 24)
    var applicationTitleFont = UIFont.systemFont(ofSize: 24)
    var loginCopyrightLabelFont = UIFont.systemFont(ofSize: 12)
    var loginFieldLabelFont = UIFont.systemFont(ofSize: 16)
    var loginHTTPSLabelFont = UIFont.systemFont(ofSize: 17)
    var loginTitleLabelFont = UIFont.systemFont(ofSize: 20)
    var loginInfoLabelFont = UIFont.systemFont(ofSize: 12)
    var loginInfoHostnameLabelFont = UIFont.systemFont(ofSize: 14)
    var needHelpTitleLabelFont: UIFont = UIFont.systemFont(ofSize: 24)
    /// TextFields
    var loginTextFieldFont = UIFont.systemFont(ofSize: 16)
    /// TextViews
    var needHelpHintTextViewFont: UIFont = UIFont.systemFont(ofSize: 14)

    // MARK: - COLORS - LOGIN COMPONENTS
    /// Buttons
    var loginButtonColor = #colorLiteral(red: 0.1764705882, green: 0.5529411765, blue: 0.1568627451, alpha: 1)
    var loginNeedHelpButtonColor = #colorLiteral(red: 0.1333333333, green: 0.4156862745, blue: 0.8431372549, alpha: 1)
    var loginAdvancedSettingsButtonColor = #colorLiteral(red: 0.05098039216, green: 0.3882352941, blue: 0.2235294118, alpha: 1)
    var loginSavePadButtonColor = #colorLiteral(red: 0.1764705882, green: 0.5529411765, blue: 0.1568627451, alpha: 1)
    /// Labels
    var productLabelColor = #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1)
    var applicationTitleColor = #colorLiteral(red: 0.1254901961, green: 0.1254901961, blue: 0.1254901961, alpha: 1)
    var loginCopyrightLabelColor = #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)
    var loginFieldLabelColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    var loginFieldDisableLabelColor = #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)
    var loginTitleLabelColor = #colorLiteral(red: 0.1254901961, green: 0.1254901961, blue: 0.1254901961, alpha: 1)
    var loginInfoLabelColor = #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)
    var needHelpTitleColor = #colorLiteral(red: 0.2745098039, green: 0.2745098039, blue: 0.2745098039, alpha: 1)
    /// TextFields
    var loginTextFieldPrimaryColor = #colorLiteral(red: 0.1764705882, green: 0.5529411765, blue: 0.1568627451, alpha: 1)
    var loginTextFieldErrorColor = #colorLiteral(red: 1, green: 0.2470588235, blue: 0.2666666667, alpha: 1)
    var loginTextFieldOnSurfaceColor = #colorLiteral(red: 0.2078431373, green: 0.2078431373, blue: 0.2078431373, alpha: 1)
    var loginTextFieldIconColor = #colorLiteral(red: 0.7098039216, green: 0.7098039216, blue: 0.7098039216, alpha: 1)
    /// Textviews
    var needHelpHintTextViewColor = #colorLiteral(red: 0.2980392157, green: 0.2980392157, blue: 0.2980392157, alpha: 1)
}
