//
//  NodeGraphData.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 12/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import Foundation

public class UpdateDictOperation: Operation
{
    var singleNodes: Set<NodeData>?
    var outDict:Dictionary<String,NodeData> = [:]
    
    override public func main()
    {
        guard let singleNodes = singleNodes else { return }
        outDict.removeAll()
        updateNodeRelations(singleNodes: singleNodes, dict: &outDict)
        updateNodeShaderText(singleNodes: singleNodes, dict: outDict)
    }
    
    private func updateNodeRelations(singleNodes: Set<NodeData>, dict: inout Dictionary<String,NodeData>) -> Void
    {
        for node in singleNodes
        {
            dfsNodeRelation(node: node, dict: &dict)
        }
    }
    
    private func dfsNodeRelation(node: NodeData?, dict: inout Dictionary<String,NodeData>)
    {
        guard let node = node else { return }
        
        if !dict.values.contains(node)
        {
            node.index = "\(dict.count)"
            dict.updateValue(node, forKey: node.index)
        }
        
        for nodeInPort in node.inPorts
        {
            for nodeConnection in nodeInPort.connections
            {
                dfsNodeRelation(node: nodeConnection.inPort.node, dict: &dict)
            }
        }
    }
    
    private func updateNodeShaderText(singleNodes: Set<NodeData>, dict : Dictionary<String,NodeData>) -> Void
    {
        for singleNode in singleNodes
        {
            var shaderListDict : Dictionary<String,Array<String>> = [:]
            dfsNodeShaderText(node: singleNode, shaderListDict: &shaderListDict)
            
            for (nodeIndex, nodeShaderBlocksList) in shaderListDict
            {
                guard let nodeData = dict[nodeIndex] else { continue }
                if type(of: nodeData).defaultCanHavePreview
                {
                    nodeData.shaderBlocksCombinedExpression = nodeShaderBlocksList.joined(separator: "\n")
                }else
                {
                    nodeData.shaderBlocksCombinedExpression = ""
                }
            }
            
        }
        
    }
    
    private func dfsNodeShaderText(node: NodeData?, shaderListDict: inout Dictionary<String,Array<String>>) -> Void
    {
        guard let node = node else { return }
        
        // add new index in the global list
        shaderListDict.updateValue([], forKey:node.index)
        
        // loop current list and for each add the current shader block
        for (_, var nodeShaderBlocksList) in shaderListDict
        {
            if nodeShaderBlocksList.contains(node.singleNodeExpressionRule())
            {
                // remove for later add, making the required reference always at the top
                nodeShaderBlocksList.removeAll { $0 == node.singleNodeExpressionRule() }
            }
            nodeShaderBlocksList.insert(node.singleNodeExpressionRule(), at: 0)
        }
        
        for nodeInPort in node.inPorts {
            for nodeConnection in nodeInPort.connections
            {
                dfsNodeShaderText(node: nodeConnection.inPort.node, shaderListDict: &shaderListDict)
            }
        }
    }
}

public class NodeGraphData: NSObject
{
    var singleNodes : Set<NodeData> = []
    private var indexNodeDataDict : Dictionary<String,NodeData> = [:]
    let updateDictOperation : UpdateDictOperation = UpdateDictOperation()
    let updateDictOperationQuene : OperationQueue = OperationQueue()
    
    public override init()
    {
        super.init()
        updateIndexNodeDataDict()
    }
    
    func getNodesTotalCount() -> Int
    {
        return indexNodeDataDict.count
    }
    
    func getNode(index: String) -> NodeData?
    {
        return indexNodeDataDict[index]
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
        for portData : NodePortData in node.inPorts
        {
            for connectionData : NodeConnectionData in portData.connections
            {
                let connectedNodeData : NodeData! = connectionData.inPort?.node
                if connectedNodeData != nil
                {
                    singleNodes.insert(connectedNodeData)
                }
            }
        }
        node.breakAllConnections()
        updateIndexNodeDataDict()
        return true
    }
    
    func canConnectNodeOutPort(outPort:NodePortData, inPort:NodePortData) -> Bool
    {
        let can : Bool = (outPort.isOutPortRelativeToNode() &&
            inPort.isInPortRelativeToNode() &&
            outPort.connections.count == 0 &&
            outPort.node?.index != inPort.node?.index &&
            outPort.requiredType.defaultCGType == inPort.requiredType.defaultCGType)
        
        return can
    }
    
    func connectNodeOutPort(outPort:NodePortData, inPort:NodePortData) -> Bool
    {
        let nodeConnection : NodeConnectionData = NodeConnectionData()
        nodeConnection.inPort = outPort
        nodeConnection.outPort = inPort
        
        inPort.connections.insert(nodeConnection)
        outPort.connections.insert(nodeConnection)
        
        if (singleNodes.contains(outPort.node!))
        {
            singleNodes.remove(outPort.node!)
        }
        updateIndexNodeDataDict()
        return true
    }
    
    func breakConnection(connection:NodeConnectionData) -> Bool
    {
        connection.inPort.connections.remove(connection)
        connection.outPort.connections.remove(connection)
        singleNodes.insert(connection.inPort.node!)
        updateIndexNodeDataDict()
        return true
    }
    
    private func updateIndexNodeDataDict() -> Void
    {
        if (updateDictOperation.isExecuting)
        {
            updateDictOperation.cancel()
        }
        updateDictOperation.singleNodes = singleNodes
        updateDictOperation.completionBlock = {
            self.indexNodeDataDict = self.updateDictOperation.outDict
        }
        updateDictOperationQuene.addOperation(updateDictOperation)
    }
}
