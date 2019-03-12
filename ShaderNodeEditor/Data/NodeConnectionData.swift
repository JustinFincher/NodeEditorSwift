//
//  NodePortConenctionData.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 12/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import Foundation

class NodeConnectionData: NSObject
{
    var inPort : NodePortData? = nil;
    weak var outPort : NodePortData? = nil;
    
    func expressionRule() -> String
    {
        return ""
    }
}
