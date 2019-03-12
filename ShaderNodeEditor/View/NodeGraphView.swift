//
//  NodeGraphView.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 12/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import Foundation
import UIKit

protocol NodeGraphViewDelegate: AnyObject
{
    func nodeGraphView(nodeGraphView: NodeGraphView, frameForNodeWithIndex: NSString) -> CGRect
    func nodeGraphView(nodeGraphView: NodeGraphView, didSelectNodeWithIndex: NSString)
}

protocol NodeGraphViewDataSource: AnyObject
{
    func nodeGraphView(nodeGraphView: NodeGraphView, nodeWithIndex: NSString) -> NodeView
    func numberOfNodes(in: NodeGraphView) -> Int
}

class NodeGraphView: UIView
{
    let containerView : NodeGraphContainerView = NodeGraphContainerView(frame: CGRect.zero)
    let drawRectView : NodeGraphDrawRectView = NodeGraphDrawRectView(frame: CGRect.zero)
    
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.postInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.postInit()
    }
    
    func postInit() -> Void
    {
        containerView.frame = self.bounds
        self.addSubview(containerView)
        
        drawRectView.frame = self.bounds
        self.addSubview(drawRectView)
    }
}
