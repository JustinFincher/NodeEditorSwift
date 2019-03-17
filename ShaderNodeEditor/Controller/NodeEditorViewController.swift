//
//  ViewController.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 11/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import UIKit

public class NodeEditorViewController: UIViewController, NodeGraphViewDelegate, NodeGraphViewDataSource,NodeListTableViewControllerSelectDelegate
{    
    let nodeEditorData : NodeGraphData = NodeGraphData()
    let nodeEditorView : NodeGraphScrollView = NodeGraphScrollView(frame: CGRect.zero, canvasSize: CGSize.init(width: 2000, height: 2000))
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = "Shader Node Editor"
        nodeEditorView.frame = self.view.bounds
        nodeEditorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(nodeEditorView)
        
        if let nodeGraphView : NodeGraphView = nodeEditorView.nodeGraphView
        {
            nodeGraphView.delegate = self;
            nodeGraphView.dataSource = self;
            nodeGraphView.reloadData()
            
            nodeEditorData.nodeGraphDataUpdatedHandler = {
                DispatchQueue.main.async {
                    nodeGraphView.reloadData()
                }
            }
        }
    }
    
    public func nodeGraphView(nodeGraphView: NodeGraphView, nodeWithIndex: String) -> NodeView?
    {
        if let nodeData = nodeEditorData.getNode(index: nodeWithIndex), let containerView = nodeGraphView.containerView
        {
            let nodeView : NodeView = NodeView(frame: nodeData.frame, data: nodeData, parent: containerView)
            return nodeView
        }else
        {
            return nil
        }
    }
    
    public func numberOfNodes(in: NodeGraphView) -> Int {
        return nodeEditorData.getNodesTotalCount()
    }
    
    public func nodeGraphView(nodeGraphView: NodeGraphView, frameForNodeWithIndex: String) -> CGRect
    {
        guard let nodeData = nodeEditorData.getNode(index: frameForNodeWithIndex) else {
            return CGRect.zero
        }
        return nodeData.frame
    }
    
    public func nodeGraphView(nodeGraphView: NodeGraphView, didSelectNodeWithIndex: String)
    {
            
    }
    
    public func requiredViewController() -> NodeEditorViewController {
        return self
    }
    
    // MARK: - NodeListTableViewControllerSelectDelegate
    public func nodeClassSelected(controller: NodeListTableViewController, nodeDataClass: AnyClass, point: CGPoint)
    {
        let nodeDataType = nodeDataClass as! NodeData.Type
        let nodeData = nodeDataType.init()
        nodeData.frame = CGRect.init(origin: point, size: nodeData.frame.size)
        if !nodeEditorData.addNode(node: nodeData)
        {
            
        }
    }
}

