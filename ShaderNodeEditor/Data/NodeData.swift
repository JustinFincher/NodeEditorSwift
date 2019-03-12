//
//  NodeData.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 12/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import Foundation
import UIKit

class NodeData: NSObject
{
    weak var graph : NodeGraphData? = nil
    var index : String = ""
    var title : String = NodeData.defaultTitle
    var frame : CGRect = CGRect.init(x: 0, y: 0, width: NodeData.defaultSize.width, height: NodeData.defaultSize.height)
    var selected : Bool = false
    var inPorts : Array<NodePortData> = NodeData.defaultInPorts
    var outPorts : Array<NodePortData> = NodeData.defaultOutPorts
    var previewOutportIndex : Int = NodeData.defaultPreviewOutportIndex
    
    class var defaultCanHavePreview: Bool { return false }
    class var defaultPreviewOutportIndex: Int { return -1 }
    class var defaultTitle: String { return "" }
    class var defaultSize: CGSize { return CGSize.init(width: 200, height: 300) }
    class var defaultCustomViewSize: CGSize { return CGSize.zero }
    class var defaultInPorts: Array<NodePortData> { return [] }
    class var defaultOutPorts: Array<NodePortData> { return [] }
    
    func shaderCommentHeader() -> String
    {
        return ""
    }
}
