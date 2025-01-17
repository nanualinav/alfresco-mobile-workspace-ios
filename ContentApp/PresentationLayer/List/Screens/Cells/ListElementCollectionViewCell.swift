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

protocol ListElementCollectionViewCellDelegate: class {
    func moreButtonTapped(for element: ListNode?,
                          in cell: ListElementCollectionViewCell)
}

class ListElementCollectionViewCell: ListSelectableCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var syncStatusImageView: UIImageView!
    weak var delegate: ListElementCollectionViewCellDelegate?

    var node: ListNode? {
        didSet {
            guard let node = node else { return }

            title.text = node.title
            subtitle.text = node.path
            iconImageView.image = FileIcon.icon(for: node)
        }
    }

    var syncStatus: ListEntrySyncStatus = .undefined {
        didSet {
            syncStatusImageView.isHidden = !(syncStatus != .undefined)
            syncStatusImageView.image = !syncStatus.rawValue.isEmpty ? UIImage(named: syncStatus.rawValue) : nil

            switch syncStatus {
            case .error:
                subtitle.text = LocalizationConstants.Labels.syncFailed
            case .inProgress:
                subtitle.text = LocalizationConstants.Labels.syncing
            default: break
            }
        }
    }

    func applyTheme(_ currentTheme: PresentationTheme?) {
        guard let currentTheme = currentTheme else { return }
        backgroundColor = currentTheme.surfaceColor
        title.applyStyleBody1OnSurface(theme: currentTheme)
        title.lineBreakMode = .byTruncatingTail
        subtitle.applyStyleCaptionOnSurface60(theme: currentTheme)
        subtitle.lineBreakMode = .byTruncatingHead
        iconImageView.tintColor = currentTheme.onSurface60Color
        moreButton.tintColor = currentTheme.onSurface60Color
        syncStatusImageView.tintColor = currentTheme.onSurface60Color
    }

    @IBAction func moreButtonTapped(_ sender: UIButton) {
        delegate?.moreButtonTapped(for: node, in: self)
    }
}
