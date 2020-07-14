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

class AlfrescoNodeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    var node: ListNode? {
        didSet {
            if let node = node {
                title.text = node.title
                subtitle.text = node.path
                iconImageView.image = FileIcon.icon(for: node.mimeType)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func applyThemingService(_ currentTheme: PresentationTheme?) {
        title.font = currentTheme?.listNodeCellTitleLabelFont
        title.textColor = currentTheme?.listNodeCellTitleLabelColor
        subtitle.font = currentTheme?.listNodeCellSubtitleLabelFont
        subtitle.textColor = currentTheme?.listNodeCellSubtitleLabelColor
    }

    @IBAction func moreButtonTapped(_ sender: UIButton) {
    }
}