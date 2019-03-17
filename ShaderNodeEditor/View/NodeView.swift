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
    weak var data : NodeData?{
        didSet
        {
            guard let data = data else
            {
                self.subviews.forEach { (view) in
                    view.removeFromSuperview()
                }
                return
            }
            inPortsContainer.removeFromSuperview()
            outPortsContainer.removeFromSuperview()
            if data.inPorts.count != 0 || data.outPorts.count != 0
            {
                inPortsContainer.frame = CGRect.init(origin: CGPoint.init(x: Constant.nodePadding,
                                                                          y: Constant.nodePadding + Constant.nodeTitleHeight + Constant.nodePadding),
                                                     size: CGSize.init(width: (self.frame.size.width - Constant.nodePadding * 3) / 2.0,
                                                                       height: CGFloat(data.inPorts.count) * Constant.nodePortHeight))
                outPortsContainer.frame = CGRect.init(origin: CGPoint.init(x: (self.frame.size.width + Constant.nodePadding) / 2.0,
                                                                           y: Constant.nodePadding + Constant.nodeTitleHeight + Constant.nodePadding),
                                                      size: CGSize.init(width: (self.frame.size.width - Constant.nodePadding * 3) / 2.0,
                                                                        height: CGFloat(data.outPorts.count) * Constant.nodePortHeight))
            }else if (data.inPorts.count == 0 || data.outPorts.count != 0)
            {
                inPortsContainer.frame = CGRect.zero
                outPortsContainer.frame = CGRect.init(origin: CGPoint.init(x: Constant.nodePadding,
                                                                           y: Constant.nodePadding + Constant.nodeTitleHeight + Constant.nodePadding),
                                                      size: CGSize.init(width: self.frame.size.width - Constant.nodePadding * 2,
                                                                        height: CGFloat(data.outPorts.count) * Constant.nodePortHeight))
            }else if (data.inPorts.count != 0 || data.outPorts.count == 0)
            {
                inPortsContainer.frame = CGRect.init(origin: CGPoint.init(x: Constant.nodePadding,
                                                                          y: Constant.nodePadding + Constant.nodeTitleHeight + Constant.nodePadding),
                                                     size: CGSize.init(width: self.frame.size.width - Constant.nodePadding * 2,
                                                                       height: CGFloat(data.inPorts.count) * Constant.nodePortHeight))
                outPortsContainer.frame = CGRect.zero
            }else
            {
                inPortsContainer.frame = CGRect.zero
                outPortsContainer.frame = CGRect.zero
            }
            
            for i in 0..<data.inPorts.count
            {
                let nodePortView : NodePortView = NodePortView(frame: CGRect.init(x: 0,
                                                                                  y: CGFloat(i) * Constant.nodePortHeight,
                                                                                  width: inPortsContainer.frame.width,
                                                                                  height: Constant.nodePortHeight),
                                                               data: data.inPorts[i],
                                                               isOutPort: false,
                                                               nodeView: self)
                inPortsContainer.addSubview(nodePortView)
                if let pan = pan, let longPress = longPress, let knotPan = nodePortView.panOnKnot
                {
                    pan.require(toFail: knotPan)
                    longPress.require(toFail: knotPan)
                }
                ports.insert(nodePortView)
            }
            
            visualEffectView.contentView.addSubview(inPortsContainer)
            visualEffectView.contentView.addSubview(outPortsContainer)
            
            previewView.removeFromSuperview()
            if data.hasPreview
            {
                previewView.frame = CGRect.init(origin: CGPoint.init(x: Constant.nodePadding,
                                                                     y: self.frame.size.height - self.frame.size.width + Constant.nodePadding),
                                                size: CGSize.init(width: self.frame.size.width - Constant.nodePadding * 2,
                                                                  height: self.frame.size.width - Constant.nodePadding * 2))
                let scene : SKScene = SKScene(size: previewView.frame.size)
                scene.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
                let shaderNode : SKSpriteNode = SKSpriteNode(color: UIColor.black, size: scene.size)
                shaderNode.shader = SKShader(source: data.previewShaderExperssion())
                scene.addChild(shaderNode)
                previewView.presentScene(scene)
                visualEffectView.contentView.addSubview(previewView)
            }
        }
    }
    weak var graphContainerView : NodeGraphContainerView?
    let visualEffectView : UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.regular))
    var attachmentBehavior : UIAttachmentBehavior?
    var pushBehavior : UIPushBehavior?
    var ports : Set<NodePortView> = []
    let previewView : SKView = SKView(frame: CGRect.zero)
    let valueView : UIView = UIView(frame: CGRect.zero)
    
    var tap: UITapGestureRecognizer?
    var longPress : UILongPressGestureRecognizer?
    var pan : UIPanGestureRecognizer?
    
    let inPortsContainer : UIView = UIView(frame: CGRect.zero)
    let outPortsContainer : UIView = UIView(frame: CGRect.zero)
    let titleLabel : UILabel = UILabel(frame: CGRect.zero)
    
    var nodeViewSelectedHandler: (() -> Void)?
    
    var scaleAnimator : UIViewPropertyAnimator?
    
    required init(frame:CGRect, data:NodeData, parent:NodeGraphContainerView)
    {
        super.init(frame: frame)
        defer
        {
            self.data = data
            self.graphContainerView = parent
            postInit()
        }
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
        
        tap = UITapGestureRecognizer(target: self,
                                     action: #selector(handleTap(recognizer:)))
        if let tap = tap
        {
            addGestureRecognizer(tap)
        }
        pan = UIPanGestureRecognizer(target: self,
                                     action: #selector(handlePan(recognizer:)))
        if let pan = pan
        {
            pan.delegate = self
            addGestureRecognizer(pan)
        }
        longPress = UILongPressGestureRecognizer(target: self,
                                                 action: #selector(handleLongPress(recognizer:)))
        if let longPress = longPress
        {
            longPress.delegate = self
            addGestureRecognizer(longPress)
        }
        
        titleLabel.frame = CGRect.init(x: Constant.nodePadding, y: Constant.nodePadding, width: self.frame.size.width - Constant.nodePadding * 2, height: Constant.nodeTitleHeight)
        titleLabel.text = data?.title
        titleLabel.font = UIFont.init(name: Constant.fontObliqueName, size: 16)
        
        visualEffectView.contentView.addSubview(titleLabel)
        
        inPortsContainer.backgroundColor = UIColor.red.withAlphaComponent(0.1)
        inPortsContainer.layer.cornerRadius = 4;
        inPortsContainer.layer.masksToBounds = true
        outPortsContainer.backgroundColor = UIColor.blue.withAlphaComponent(0.1)
        outPortsContainer.layer.cornerRadius = 4;
        outPortsContainer.layer.masksToBounds = true
        
        previewView.layer.cornerRadius = 8
        previewView.layer.masksToBounds = true
        previewView.showsFPS = true
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
        let locationInSelf = recognizer.location(in: self)
        
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
                    pushBehavior.pushDirection = CGVector.init(dx: velocityInParent.x / 4.0 / pow(length, 0.5) ,
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
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil
        {
            previewView.scene?.removeAllChildren()
            previewView.presentScene(nil)
            data = nil
            while subviews.count > 0
            {
                var view = subviews.last
                view?.removeFromSuperview()
                view = nil
            }
        }
    }
}
