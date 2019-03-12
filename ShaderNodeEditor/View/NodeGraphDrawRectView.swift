//
//  NodeGraphDrawRectView.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 12/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import Foundation
import UIKit

class NodeGraphDrawRectView: UIView
{
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
        
    }
    
    override func draw(_ rect: CGRect)
    {
        
    }
}
