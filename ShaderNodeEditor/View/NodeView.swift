//
//  NodeView.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 12/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

public class NodeView: UIView, UIGestureRecognizerDelegate
{
    
    weak var data : NodeData?
    weak var graphContainerView : NodeGraphContainerView?
    let visualEffectView : UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.regular))
    var attachmentBehavior : UIAttachmentBehavior?
    var pushBehavior : UIPushBehavior?
    let ports : Set<NodePortView> = []
    let previewView : SKView = SKView(frame: CGRect.zero)
    let valueView : UIView = UIView(frame: CGRect.zero)
    
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                             action: #selector(handleTap(recognizer:)))
    let longPress : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self,
                                                                                action: #selector(handleLongPress(recognizer:)))
    let pan : UIPanGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                              action: #selector(handlePan(recognizer:)))
    
    let inPortsContainer : UIView = UIView(frame: CGRect.zero)
    let outPortsContainer : UIView = UIView(frame: CGRect.zero)
    
    var nodeViewSelectedHandler: (() -> Void)?
    
    var scaleAnimator : UIViewPropertyAnimator?
    
    required init(frame:CGRect, data:NodeData, parent:NodeGraphContainerView)
    {
        super.init(frame: frame)
        self.data = data
        self.graphContainerView = parent
        postInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        postInit()
    }
    
    func postInit() -> Void
    {
        backgroundColor = UIColor.clear
        visualEffectView.frame = bounds
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        visualEffectView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        visualEffectView.layer.shadowColor = UIColor.black.cgColor
        visualEffectView.layer.shadowOffset = CGSize.zero
        visualEffectView.layer.shadowOpacity = 1.0
        visualEffectView.layer.shadowRadius = 32
        visualEffectView.layer.masksToBounds = true
        visualEffectView.layer.cornerRadius = 8
        addSubview(visualEffectView)
        
        addGestureRecognizer(tap)
        pan.delegate = self
        addGestureRecognizer(pan)
        longPress.delegate = self
        addGestureRecognizer(longPress)
    }
    
    func updateNode() -> Void
    {
        data?.frame = self.frame
        self.visualEffectView.layer.borderColor = data?.isSelected ?? false ? UIColor.orange.withAlphaComponent(0.6).cgColor : UIColor.clear.cgColor
        self.visualEffectView.layer.borderWidth = data?.isSelected ?? false ? 4 : 0
        self.graphContainerView?.dynamicAnimator?.updateItem(usingCurrentState: self)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - Gesture Handler
    
    @objc func handleTap(recognizer : UITapGestureRecognizer) -> Void
    {
        graphContainerView?.bringSubviewToFront(self)
        nodeViewSelectedHandler?()
        if let pushBehavior = pushBehavior
        {
            self.graphContainerView?.dynamicAnimator?.removeBehavior(pushBehavior)
        }
        if let scaleAnimator = scaleAnimator
        {
            scaleAnimator.stopAnimation(true)
        }
        scaleAnimator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1, animations: {
            self.transform = CGAffineTransform.init(scaleX: Constant.nodeScaleZoomed, y: Constant.nodeScaleZoomed)
            self.graphContainerView?.dynamicAnimator?.updateItem(usingCurrentState: self)
        })
        scaleAnimator?.addAnimations({
            self.transform = CGAffineTransform.init(scaleX: Constant.nodeScaleNormal, y: Constant.nodeScaleNormal)
        }, delayFactor: 0.5)
        scaleAnimator?.startAnimation()
        
        if self.isFirstResponder
        {
            self.resignFirstResponder()
            UIMenuController.shared.setMenuVisible(false, animated: true)
        }
    }
    
    @objc func handleLongPress(recognizer : UILongPressGestureRecognizer) -> Void
    {
        graphContainerView?.bringSubviewToFront(self)
        nodeViewSelectedHandler?()
        switch recognizer.state
        {
        case .began:
            if let pushBehavior = pushBehavior
            {
                self.graphContainerView?.dynamicAnimator?.removeBehavior(pushBehavior)
            }
            scaleAnimator?.stopAnimation(true)
            scaleAnimator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1, animations: {
                self.transform = CGAffineTransform.init(scaleX: Constant.nodeScaleZoomed, y: Constant.nodeScaleZoomed)
                self.graphContainerView?.dynamicAnimator?.updateItem(usingCurrentState: self)
            })
            scaleAnimator?.startAnimation()
            self.becomeFirstResponder()
            UIMenuController.shared.setTargetRect(bounds, in: self)
            UIMenuController.shared.setMenuVisible(true, animated: true)
            break
        case .ended:
            scaleAnimator?.stopAnimation(true)
            scaleAnimator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1, animations: {
                self.transform = CGAffineTransform.init(scaleX: Constant.nodeScaleNormal, y: Constant.nodeScaleNormal)
                self.graphContainerView?.dynamicAnimator?.updateItem(usingCurrentState: self)
            })
            scaleAnimator?.startAnimation()
            break
        default: break
        }
    }
    
    @objc func handlePan(recognizer : UIPanGestureRecognizer) -> Void
    {
        graphContainerView?.bringSubviewToFront(self)
        nodeViewSelectedHandler?()
        let velocityInParent = recognizer.velocity(in: graphContainerView)
        let locationInSelf = recognizer.location(in: graphContainerView)
        
        switch recognizer.state
        {
        case .began:
            if let pushBehavior = pushBehavior
            {
                self.graphContainerView?.dynamicAnimator?.removeBehavior(pushBehavior)
            }
            scaleAnimator?.stopAnimation(true)
            scaleAnimator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1, animations: {
                self.transform = CGAffineTransform.init(scaleX: Constant.nodeScaleZoomed, y: Constant.nodeScaleZoomed)
                self.graphContainerView?.dynamicAnimator?.updateItem(usingCurrentState: self)
            })
            scaleAnimator?.addCompletion({ (finalPosition) in
                self.transform = CGAffineTransform.init(scaleX: Constant.nodeScaleZoomed, y: Constant.nodeScaleZoomed)
                self.graphContainerView?.dynamicAnimator?.updateItem(usingCurrentState: self)
            })
            scaleAnimator?.startAnimation()
            
            if let attachmentBehavior = attachmentBehavior
            {
                self.graphContainerView?.dynamicAnimator?.removeBehavior(attachmentBehavior)
            }
            attachmentBehavior = UIAttachmentBehavior(item: self,
                                                      offsetFromCenter: UIOffset.init(horizontal: locationInSelf.x - self.bounds.size.width / 2.0,
                                                                                      vertical: locationInSelf.y - self.bounds.size.height / 2.0),
                                                      attachedToAnchor: recognizer.location(in: self.graphContainerView))
            attachmentBehavior?.action = {
                self.updateNode()
                self.transform = self.transform.scaledBy(x: Constant.nodeScaleZoomed, y: Constant.nodeScaleZoomed)
            }
            if let attachmentBehavior = attachmentBehavior
            {
                graphContainerView?.dynamicAnimator?.addBehavior(attachmentBehavior)
            }
            self.resignFirstResponder()
            UIMenuController.shared.setMenuVisible(false, animated: true)
            break
        case .changed:
            if let attachmentBehavior = attachmentBehavior
            {
                attachmentBehavior.anchorPoint = recognizer.location(in: self.graphContainerView)
            }
            break
        case .ended:
            if let attachmentBehavior = attachmentBehavior
            {
                graphContainerView?.dynamicAnimator?.removeBehavior(attachmentBehavior)
            }
            scaleAnimator?.stopAnimation(true)
            scaleAnimator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1, animations: {
                self.transform = CGAffineTransform.init(scaleX: Constant.nodeScaleNormal, y: Constant.nodeScaleNormal)
                self.graphContainerView?.dynamicAnimator?.updateItem(usingCurrentState: self)
            })
            scaleAnimator?.addCompletion({ (finalPosition) in
                self.transform = CGAffineTransform.init(scaleX: Constant.nodeScaleNormal, y: Constant.nodeScaleNormal)
                self.graphContainerView?.dynamicAnimator?.updateItem(usingCurrentState: self)
            })
            scaleAnimator?.startAnimation()
            
            if let pushBehavior = pushBehavior
            {
                graphContainerView?.dynamicAnimator?.removeBehavior(pushBehavior)
            }
            pushBehavior = UIPushBehavior(items: [self], mode: .instantaneous)
            if let pushBehavior = pushBehavior
            {
                pushBehavior.action = {
                    self.updateNode()
                }
                let length = hypot(velocityInParent.x, velocityInParent.y)
                if length > 100
                {
                    pushBehavior.pushDirection = CGVector.init(dx: velocityInParent.x / 4.0 / pow(length, 0.5),
                                                                dy: velocityInParent.y / 4.0 / pow(length, 0.5))
                    graphContainerView?.dynamicAnimator?.addBehavior(pushBehavior)
                }
            }
            break
        default:
            break
        }
    }
    
    
    // MARK : - Menu
    
    public override func delete(_ sender: Any?)
    {
        if let data = data {
            graphContainerView?.nodeGraphView?.dataSource?.delete(node: data)
        }
    }
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(delete(_:))
    }
    
    public override var canBecomeFirstResponder: Bool
    {
        return true
    }
}
