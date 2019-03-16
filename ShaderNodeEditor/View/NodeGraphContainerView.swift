//
//  NodeGraphContainerView.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 12/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import Foundation
import UIKit

public protocol NodeGraphContainerViewDelegate: AnyObject
{
    func nodeMoved(nodeGraphContainerView: NodeGraphContainerView) -> Void
    func showNodeList(nodeGraphContainerView: NodeGraphContainerView,location:CGPoint) -> Void
}

public class NodeGraphContainerView: UIView
{
    weak var delegate: NodeGraphContainerViewDelegate?
    weak var nodeGraphView : NodeGraphView?
    var dynamicAnimator : UIDynamicAnimator?
    private var dynamicItemBehavior : UIDynamicItemBehavior = UIDynamicItemBehavior(items: [])
    private var collisionBehavior : UICollisionBehavior = UICollisionBehavior(items: [])
    private var longPress: UILongPressGestureRecognizer?
    
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
        dynamicAnimator = UIDynamicAnimator(referenceView: self)
        
        guard let dynamicAnimator = dynamicAnimator else
        {
            return
        }
        
        dynamicItemBehavior.allowsRotation = false
        dynamicItemBehavior.friction = 1000
        dynamicItemBehavior.elasticity = 0.9
        dynamicItemBehavior.resistance = 0.6
        dynamicItemBehavior.action = {}
        dynamicAnimator.addBehavior(dynamicItemBehavior)
        
        collisionBehavior.collisionMode = .boundaries
        collisionBehavior.action = {}
        dynamicAnimator.addBehavior(collisionBehavior)
        
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
        if let longPress = longPress
        {
            self.addGestureRecognizer(longPress)
        }
    }
    
    @objc func handleLongPress(recognizer : UILongPressGestureRecognizer) -> Void
    {
        switch recognizer.state
        {
        case .began:
            recognizer.state = .ended
            let point = recognizer.location(in: self)
            delegate?.showNodeList(nodeGraphContainerView: self, location: point)
            break
        case .possible: break
        case .changed: break
        case .ended: break
        case .cancelled: break
        case .failed: break
        }
    }
    
    @objc func handleKnotPan(recognizer : UILongPressGestureRecognizer) -> Void
    {
        
    }
    
    func reloadData() -> Void {
        
    }
}
