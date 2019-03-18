//
//  NodeGraphDrawRectView.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 12/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import Foundation
import UIKit

public class NodeGraphDrawRectView: UIView, NodeGraphContainerViewDataSource
{
    weak var nodeGraphView : NodeGraphView?
    
    var dragging : Bool = false
    var position : CGPoint = CGPoint.zero
    var draggingRelatedPortView : NodePortView? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.postInit()
    }
    
    required init(frame: CGRect, nodeGraphView: NodeGraphView)
    {
        super.init(frame: frame)
        self.nodeGraphView = nodeGraphView
        self.postInit()
    }
    
    func postInit() -> Void
    {
        isUserInteractionEnabled = true
        isOpaque = false
        backgroundColor = UIColor.clear
    }
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?
    {
        setNeedsDisplay()
        return nil
    }
    
    override public func draw(_ rect: CGRect)
    {
        guard let nodeGraphView = nodeGraphView,
            let nodeGraphDataSource = nodeGraphView.dataSource
            else
        {
            return
        }
        if dragging
        {
            var canConnect : Bool = false
        }
        
    }
    
    func reloadData() -> Void {
        
    }
    
    // MARK : - NodeGraphContainerViewDataSource
    public func selectedNodeCurrentInteractiveState(point: CGPoint, dragging: Bool, fromNode: NodePortView?)
    {
        self.dragging = dragging
        self.position = point
        self.draggingRelatedPortView = fromNode
        setNeedsDisplay()
    }
}
