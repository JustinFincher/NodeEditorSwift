//
//  AddNodeData.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 16/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import UIKit

@objc public class FloatAddNodeData: NodeData
{
    override class var defaultTitle: String { return "Float Add (float c = a + b)" }
    override class var defaultCanHavePreview: Bool { return true }
    override class var defaultPreviewOutportIndex: Int { return 0 }
    override class var defaultInPorts: Array<NodePortData>
    {
        return [
            FloatNodePortData(title: "A"),
            FloatNodePortData(title: "B")
        ]
    }
    override class var defaultOutPorts: Array<NodePortData>
    {
        return [
            FloatNodePortData(title: "C")
        ] }
}
