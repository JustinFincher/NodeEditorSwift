//
//  NodeGraphData.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 12/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import Foundation

class NodeGraphData: NSObject
{
    var singleNodes : Set<NodeData> = []
    private let indexNodeDataDict : Dictionary<String,NodeData> = [:]
    
    override init()
    {
        super.init()
    }
    
    func getNodesTotalCount() -> Int
    {
        return indexNodeDataDict.count
    }
    
    func addNode(node: NodeData) -> Bool
    {
        node.index = NSNumber(integerLiteral: getNodesTotalCount()).stringValue
        singleNodes.insert(node)
        updateIndexNodeDataDict()
        return true
    }
    
    func removeNode(node: NodeData) -> Bool
    {
        if singleNodes.contains(node)
        {
            self.singleNodes.remove(node)
        }
        
        //TODO
        return true
    }
    
    func canConnectNodeOutPort(outPort:NodePortData, withNodeInPort:NodePortData) -> Bool
    {
        return true
    }
    
    func connectNodeOutPort(outPort:NodePortData, withNodeInPort:NodePortData) -> Bool
    {
        return true
    }
    
    func breakConnection(connection:NodeConnectionData) -> Bool
    {
        return true
    }
    
    private func updateIndexNodeDataDict() -> Void
    {
        
    }
}
