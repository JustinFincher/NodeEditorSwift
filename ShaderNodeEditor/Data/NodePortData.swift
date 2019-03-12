//
//  NodePortData.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 12/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import Foundation

class NodePortData: NSObject
{
    weak var node : NodeData? = nil
    
    class var defaultTitle : String { return "" }
    class var defaultRequiredType : CGData.Type { return CGData.self }
    
    var index : String = ""
    var title : String = defaultTitle
    var connections : Set<NodeConnectionData> = []
    var requiredType : CGData.Type = defaultRequiredType
    
    func getPortDefaultValueExpression() -> String
    {
        return requiredType.defaultCGType + " " + getPortVariableName() + " = " + requiredType.defaultCGValue
    }
    
    func getPortVariableName() -> String
    {
        return ""
    }
    
    func breakAllConnections() -> Void
    {
        
    }
    
    func isInPortRelativeToNode() -> Bool
    {
        return true
    }
    
    func isOutPortRelativeToNode() -> Bool
    {
        return true
    }
    
    func isInPortRelativeToConnection() -> Bool
    {
        return true
    }
    
    func isOutPortRelativeToConnection() -> Bool
    {
        return true
    }
}
