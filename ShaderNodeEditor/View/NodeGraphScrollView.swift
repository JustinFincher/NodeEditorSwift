//
//  NodeGraphScrollView.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 15/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import UIKit

public class NodeGraphScrollView: UIScrollView, UIScrollViewDelegate
{
    var nodeGraphView : NodeGraphView?
    var canvasSize : CGSize = CGSize.zero
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.postInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.postInit()
    }
    
    init(frame: CGRect, canvasSize: CGSize)
    {
        super.init(frame: frame)
        self.canvasSize = canvasSize
        self.postInit()
    }
    
    func postInit() -> Void
    {
        self.backgroundColor = UIColor.init(displayP3Red: 239.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)
        self.isScrollEnabled = true
        self.isUserInteractionEnabled = true
        self.maximumZoomScale = 1
        self.minimumZoomScale = 0.2
        self.delegate = self
        nodeGraphView = NodeGraphView(frame: CGRect.init(origin: CGPoint.zero, size: canvasSize), parentScrollView: self)
        self.addSubview(nodeGraphView!)
        self.contentSize = (nodeGraphView?.frame.size)!
    }
    
    private func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return scrollView == self ? nodeGraphView : nil
    }
}
