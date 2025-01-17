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

import Foundation
import AlfrescoContent

struct FavoritesNodeMapper {
    static func map(_ entries: [FavoriteEntry]) -> [ListNode] {
        var nodes: [ListNode] = []
        for entry in entries {
            if let nodeFile = entry.entry.target.file {
                nodes.append(self.create(from: nodeFile))
            } else if let nodeFolder = entry.entry.target.folder {
                nodes.append(self.create(from: nodeFolder))
            } else if let nodeSite = entry.entry.target.site {
                nodes.append(self.create(from: nodeSite))
            }
        }
        return nodes
    }

    private static func create(from node: FavoriteTargetNode) -> ListNode {
        let path = node.path?.elements?.compactMap({ $0.name })
            .joined(separator: " \u{203A} ") ?? ""
        var mimeType = node.content?.mimeType
        var nodeType = NodeType.file
        if node.isFolder {
            mimeType = "cm:folder"
            nodeType = NodeType.folder
        }
        return ListNode(guid: node._id,
                        mimeType: mimeType,
                        title: node.name,
                        path: path,
                        modifiedAt: node.modifiedAt,
                        nodeType: nodeType,
                        favorite: true,
                        allowableOperations: node.allowableOperations ?? [],
                        isFile: node.isFile,
                        isFolder: node.isFolder)
    }

    private static func create(from node: Site) -> ListNode {
        return ListNode(guid: node.guid,
                        siteID: node._id,
                        mimeType: "st:site",
                        title: node.title,
                        path: "",
                        modifiedAt: nil,
                        nodeType: .site,
                        favorite: true,
                        siteRole: node.role?.rawValue)
    }
}
