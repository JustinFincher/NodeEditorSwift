//
//  FloatNodeData.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 16/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import UIKit

@objc public class FloatNodeData: NodeData
{
    override class var defaultTitle: String { return "Number (float a)" }
    override class var defaultCanHavePreview: Bool { return true }
}
