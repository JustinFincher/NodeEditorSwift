//
//  NodeGraphDrawRectView.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 12/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import Foundation
import UIKit

public class NodeGraphDrawRectView: UIView
{
    weak var nodeGraphView : NodeGraphView?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.postInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.postInit()
    }
    
    init(frame: CGRect, nodeGraphView: NodeGraphView)
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
        
    }
    
    func reloadData() -> Void {
        
    }
}
