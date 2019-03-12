//
//  ViewController.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 11/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import UIKit

class NodeEditorViewController: UIViewController
{
    let nodeEditorView : NodeGraphView = NodeGraphView(frame: CGRect.zero)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = "Shader Node Editor"
        
        nodeEditorView.frame = self.view.bounds
        nodeEditorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(nodeEditorView)
    }
}

