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
        backgroundColor = UIColor.clear
        dynamicAnimator = UIDynamicAnimator(referenceView: self)
        
        guard let dynamicAnimator = dynamicAnimator else
        {
            return
        }
        
        dynamicItemBehavior.allowsRotation = false
        dynamicItemBehavior.friction = 1000
        dynamicItemBehavior.elasticity = 0.9
        dynamicItemBehavior.resistance = 0.6
        dynamicItemBehavior.action = {
            let nodeViews = self.subviews.filter{$0 is NodeView}.compactMap{$0 as? NodeView}
            for view : NodeView in nodeViews
            {
                view.updateNode()
            }
            self.delegate?.nodeMoved(nodeGraphContainerView: self)
        }
        dynamicAnimator.addBehavior(dynamicItemBehavior)
        
        collisionBehavior.collisionMode = .boundaries
        collisionBehavior.action = {
            let nodeViews = self.subviews.filter{$0 is NodeView}.compactMap{$0 as? NodeView}
            for view : NodeView in nodeViews
            {
                view.updateNode()
            }
            self.delegate?.nodeMoved(nodeGraphContainerView: self)
        }
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
        default: break
        }
    }
    
    @objc func handleKnotPan(recognizer : UILongPressGestureRecognizer) -> Void
    {
        
    }
    
    func reloadData() -> Void
    {
        let nodeViews = self.subviews.filter{$0 is NodeView}.compactMap{$0 as? NodeView}
        for view : NodeView in nodeViews
        {
            self.collisionBehavior.removeItem(view)
            self.dynamicItemBehavior.removeItem(view)
            view.data?.frame = view.frame
            view.removeFromSuperview()
        }
        guard let nodeGraphView = self.nodeGraphView, let dataSource = nodeGraphView.dataSource else
        {
            return
        }
        let count : Int = dataSource.numberOfNodes(in: nodeGraphView)
        for i in 0 ..< count
        {
            guard let nodeView = dataSource.nodeGraphView(nodeGraphView: nodeGraphView, nodeWithIndex: "\(i)") else
            {
                // WTF?
                continue
            }
            nodeView.nodeViewSelectedHandler = {
                self.subviews.filter{$0 is NodeView}.compactMap{$0 as? NodeView}.forEach({ (eachNodeView) in
                    eachNodeView.data?.isSelected = eachNodeView.data?.index == nodeView.data?.index
                    eachNodeView.updateNode()
                })
            }
            self.addSubview(nodeView)
            
            // TODO add recogiser
            self.nodeGraphView?.parentScrollView?.panGestureRecognizer.require(toFail: nodeView.pan)
            self.nodeGraphView?.parentScrollView?.panGestureRecognizer.require(toFail: nodeView.longPress)
            self.nodeGraphView?.parentScrollView?.pinchGestureRecognizer!.require(toFail: nodeView.pan)
            self.nodeGraphView?.parentScrollView?.pinchGestureRecognizer!.require(toFail: nodeView.longPress)
            self.longPress?.require(toFail: nodeView.pan)
            self.longPress?.require(toFail: nodeView.longPress)
            self.dynamicItemBehavior.addItem(nodeView)
            self.collisionBehavior.addItem(nodeView)
        }
        self.delegate?.nodeMoved(nodeGraphContainerView: self)
    }
}
