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
    
    class var defaultCanHavePreview: Bool { return false }
    class var defaultPreviewOutportIndex: Int { return -1 }
    class var defaultTitle: String { return "" }
    class var defaultSize: CGSize { return CGSize.init(width: 200, height: 300) }
    class var defaultCustomViewSize: CGSize { return CGSize.zero }
    class var defaultInPorts: Array<NodePortData> { return [] }
    class var defaultOutPorts: Array<NodePortData> { return [] }
    
    var index : String = ""
    var title : String = defaultTitle
    var frame : CGRect = CGRect.init(x: 0, y: 0, width: defaultSize.width, height: defaultSize.height)
    var selected : Bool = false
    var inPorts : Array<NodePortData> = defaultInPorts
    var outPorts : Array<NodePortData> = defaultOutPorts
    var previewOutportIndex : Int = defaultPreviewOutportIndex

    func isSingleNode() -> Bool
    {
        return graph?.singleNodes.contains(self) ?? false
    }
    
    func shaderCommentHeader() -> String
    {
        return ""
    }
    
    func breakAllConnections() -> Void
    {
        
    }
    
    func expressionRule() -> String
    {
        return ""
    }
    
    func previewShaderExperssion() -> String
    {
        return ""
    }
}
