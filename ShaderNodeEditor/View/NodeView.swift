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
    
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
    let longPress : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
    let pan : UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
    
    let inPortsContainer : UIView = UIView(frame: CGRect.zero)
    let outPortsContainer : UIView = UIView(frame: CGRect.zero)
    
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
        visualEffectView.layer.shadowRadius = 18
        visualEffectView.layer.masksToBounds = true
        visualEffectView.layer.cornerRadius = 8
        addSubview(visualEffectView)
        
        addGestureRecognizer(tap)
        pan.delegate = self
        addGestureRecognizer(pan)
        longPress.delegate = self
        addGestureRecognizer(longPress)
    }
    
    func updateNodeData() -> Void
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
        
    }
    
    @objc func handleLongPress(recognizer : UILongPressGestureRecognizer) -> Void
    {
        
    }
    
    @objc func handlePan(recognizer : UIPanGestureRecognizer) -> Void
    {
        
    }
}
