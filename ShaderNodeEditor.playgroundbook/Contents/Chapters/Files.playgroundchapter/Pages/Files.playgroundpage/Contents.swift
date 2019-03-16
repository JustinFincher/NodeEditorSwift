import Foundation
import UIKit
import PlaygroundSupport

//
//  CGData.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 13/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import Foundation

public class CGData: NSObject
{
    class var defaultCGType : String { return "float" }
    class var defaultCGValue : String { return "0.0" }
}
//
//  Constant.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 15/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import UIKit

public class Constant: NSObject
{
    
}

public extension String
{
    
}
//
//  Dynamic.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 12/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import Foundation

public class Dynamic<T> {
    typealias Listener = (T) -> Void
    var listener: Listener?
    
    func bind(listener: Listener?) {
        self.listener = listener
    }
    
    func bindAndFire(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ v: T) {
        value = v
    }
}
//
//  Extensions.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 16/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import Foundation


public extension NSObject
{
    public class func getClassHierarchy() -> [AnyClass] {
        var hierarcy = [AnyClass]()
        hierarcy.append(self.classForCoder())
        var currentSuper: AnyClass? = class_getSuperclass(self.classForCoder())
        while currentSuper != nil {
            hierarcy.append(currentSuper!)
            currentSuper = class_getSuperclass(currentSuper)
        }
        
        return hierarcy
    }
    
    public class func getAllClasses() -> [AnyClass] {
        let expectedClassCount = objc_getClassList(nil, 0)
        let allClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedClassCount))
        
        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
        let actualClassCount: Int32 = objc_getClassList(autoreleasingAllClasses, expectedClassCount)
        
        var classes = [AnyClass]()
        for i in 0 ..< actualClassCount {
            if let currentClass: AnyClass = allClasses[Int(i)] {
                classes.append(currentClass)
            }
        }
        
        allClasses.deallocate()
        return classes
    }
    
    public class func directSubclasses() -> [AnyClass]
    {
        var result: Array<AnyClass> = []
        
        let expectedClassCount = objc_getClassList(nil, 0)
        let allClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedClassCount))
        
        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
        let actualClassCount: Int32 = objc_getClassList(autoreleasingAllClasses, expectedClassCount)
        
        for i in 0 ..< actualClassCount
        {
            if let currentClass: AnyClass = allClasses[Int(i)]
            {
                if let currentSuper = class_getSuperclass(currentClass)
                {
                    if (String(describing: currentSuper) == String(describing: self))
                    {
                        result.append(currentClass)
                    }
                }
            }
        }
        allClasses.deallocate()
        return result
    }
}
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
}
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
}
//
//  NodePortConenctionData.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 12/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import Foundation

public class NodeConnectionData: NSObject
{
    var inPort : NodePortData! = nil;
    weak var outPort : NodePortData! = nil;
    
    func expressionRule() -> String
    {
        let outputRequiredCGType = outPort.requiredType.defaultCGType
        let outPortName = outPort.getPortVariableName()
        let inPortName = inPort.getPortVariableName()
        return "\(outputRequiredCGType) \(outPortName) = \(inPortName)"
    }
}
//
//  NodeData.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 12/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import Foundation
import UIKit

public enum NodeType
{
    case Generator
    case Comsumer
    case Sensor
    case Modifier
}
@objc public class NodeData: NSObject
{
    weak var graph : NodeGraphData? = nil
    
    class var defaultCanHavePreview: Bool { return false }
    class var defaultPreviewOutportIndex: Int { return -1 }
    class var defaultTitle: String { return "" }
    class var defaultSize: CGSize { return CGSize.init(width: 200, height: 300) }
    class var defaultCustomViewSize: CGSize { return CGSize.zero }
    class var defaultInPorts: Array<NodePortData> { return [] }
    class var defaultOutPorts: Array<NodePortData> { return [] }
    
    var index : String = ""
    {
        didSet
        {
            var portIndex : Int = 0
            for nodePort in inPorts + outPorts
            {
                nodePort.node = self
                nodePort.index = "\(nodePort.node!.index)_\(portIndex)"
                portIndex += 1
            }
        }
    }
    var title : String = defaultTitle
    var frame : CGRect = CGRect.init(x: 0, y: 0, width: defaultSize.width, height: defaultSize.height)
    var selected : Bool = false
    var inPorts : Array<NodePortData> = defaultInPorts
    var outPorts : Array<NodePortData> = defaultOutPorts
    var previewOutportIndex : Int = defaultPreviewOutportIndex
    
    // single node shader block, need to override
    func singleNodeExpressionRule() -> String
    {
        return ""
    }
    
    // combined shader blocks only, do not override
    var shaderBlocksCombinedExpression : String = ""
    
    // preview shader expression gl_FragColor only, need to override
    func shaderFinalColorExperssion() -> String
    {
        let zero : Float = 0;
        return String(format: "gl_FragColor = vec4(%.8f,%.8f,%.8f,%.8f)",zero,zero,zero,zero)
    }
    
    func previewShaderExperssion() -> String
    {
        return String(format:
            """
                void main() {
                %@
                %@
                } // From Node %@
            """,
                      shaderBlocksCombinedExpression,
                      shaderFinalColorExperssion(),
                      index)
    }
    
    func isSingleNode() -> Bool
    {
        return graph?.singleNodes.contains(self) ?? false
    }
    
    func shaderCommentHeader() -> String
    {
        return "\n// \(type(of: self)) Index \(index)"
    }
    
    func breakAllConnections() -> Void
    {
        
    }
    
    func nodeType() -> NodeType
    {
        return NodeType.Generator
    }
    
}
//
//  ViewController.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 11/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import UIKit

public class NodeEditorViewController: UIViewController, NodeGraphViewDelegate, NodeGraphViewDataSource
{
    let nodeEditorData : NodeGraphData = NodeGraphData()
    let nodeEditorView : NodeGraphScrollView = NodeGraphScrollView(frame: CGRect.zero, canvasSize: CGSize.init(width: 2000, height: 2000))
    
    public init()
    {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = "Shader Node Editor"
        
        nodeEditorView.frame = self.view.bounds
        nodeEditorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(nodeEditorView)
        
        if let nodeGraphView : NodeGraphView = nodeEditorView.nodeGraphView
        {
            nodeGraphView.delegate = self;
            nodeGraphView.dataSource = self;
            nodeGraphView.reloadData()
        }
    }
    
    public func nodeGraphView(nodeGraphView: NodeGraphView, nodeWithIndex: String) -> NodeView?
    {
        guard let nodeData = nodeEditorData.getNode(index: nodeWithIndex) else {
            return nil
        }
        let nodeView : NodeView = NodeView()
        nodeView.data = nodeData
        return nodeView
    }
    
    public func numberOfNodes(in: NodeGraphView) -> Int {
        return nodeEditorData.getNodesTotalCount()
    }
    
    public func nodeGraphView(nodeGraphView: NodeGraphView, frameForNodeWithIndex: String) -> CGRect
    {
        guard let nodeData = nodeEditorData.getNode(index: frameForNodeWithIndex) else {
            return CGRect.zero
        }
        return nodeData.frame
    }
    
    public func nodeGraphView(nodeGraphView: NodeGraphView, didSelectNodeWithIndex: String)
    {
        
    }
    
    public func requiredViewController() -> UIViewController {
        return self
    }
}

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
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.postInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.postInit()
    }
    
    init(frame: CGRect, nodeGraphView: NodeGraphView)
    {
        super.init(frame: frame)
        self.nodeGraphView = nodeGraphView
        self.postInit()
    }
    
    func postInit() -> Void
    {
        dynamicAnimator = UIDynamicAnimator(referenceView: self)
        
        guard let dynamicAnimator = dynamicAnimator else
        {
            return
        }
        
        dynamicItemBehavior.allowsRotation = false
        dynamicItemBehavior.friction = 1000
        dynamicItemBehavior.elasticity = 0.9
        dynamicItemBehavior.resistance = 0.6
        dynamicItemBehavior.action = {}
        dynamicAnimator.addBehavior(dynamicItemBehavior)
        
        collisionBehavior.collisionMode = .boundaries
        collisionBehavior.action = {}
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
        case .possible: break
        case .changed: break
        case .ended: break
        case .cancelled: break
        case .failed: break
        }
    }
    
    @objc func handleKnotPan(recognizer : UILongPressGestureRecognizer) -> Void
    {
        
    }
    
    func reloadData() -> Void {
        
    }
}
//
//  NodeGraphData.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 12/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import Foundation

public class UpdateDictOperation: Operation
{
    var singleNodes: Set<NodeData>?
    var outDict:Dictionary<String,NodeData> = [:]
    
    override public func main()
    {
        guard let singleNodes = singleNodes else { return }
        outDict.removeAll()
        updateNodeRelations(singleNodes: singleNodes, dict: &outDict)
        updateNodeShaderText(singleNodes: singleNodes, dict: outDict)
    }
    
    private func updateNodeRelations(singleNodes: Set<NodeData>, dict: inout Dictionary<String,NodeData>) -> Void
    {
        for node in singleNodes
        {
            dfsNodeRelation(node: node, dict: &dict)
        }
    }
    
    private func dfsNodeRelation(node: NodeData?, dict: inout Dictionary<String,NodeData>)
    {
        guard let node = node else { return }
        
        if !dict.values.contains(node)
        {
            node.index = "\(dict.count)"
            dict.updateValue(node, forKey: node.index)
        }
        
        for nodeInPort in node.inPorts
        {
            for nodeConnection in nodeInPort.connections
            {
                dfsNodeRelation(node: nodeConnection.inPort.node, dict: &dict)
            }
        }
    }
    
    private func updateNodeShaderText(singleNodes: Set<NodeData>, dict : Dictionary<String,NodeData>) -> Void
    {
        for singleNode in singleNodes
        {
            var shaderListDict : Dictionary<String,Array<String>> = [:]
            dfsNodeShaderText(node: singleNode, shaderListDict: &shaderListDict)
            
            for (nodeIndex, nodeShaderBlocksList) in shaderListDict
            {
                guard let nodeData = dict[nodeIndex] else { continue }
                if type(of: nodeData).defaultCanHavePreview
                {
                    nodeData.shaderBlocksCombinedExpression = nodeShaderBlocksList.joined(separator: "\n")
                }else
                {
                    nodeData.shaderBlocksCombinedExpression = ""
                }
            }
            
        }
        
    }
    
    private func dfsNodeShaderText(node: NodeData?, shaderListDict: inout Dictionary<String,Array<String>>) -> Void
    {
        guard let node = node else { return }
        
        // add new index in the global list
        shaderListDict.updateValue([], forKey:node.index)
        
        // loop current list and for each add the current shader block
        for (_, var nodeShaderBlocksList) in shaderListDict
        {
            if nodeShaderBlocksList.contains(node.singleNodeExpressionRule())
            {
                // remove for later add, making the required reference always at the top
                nodeShaderBlocksList.removeAll { $0 == node.singleNodeExpressionRule() }
            }
            nodeShaderBlocksList.insert(node.singleNodeExpressionRule(), at: 0)
        }
        
        for nodeInPort in node.inPorts {
            for nodeConnection in nodeInPort.connections
            {
                dfsNodeShaderText(node: nodeConnection.inPort.node, shaderListDict: &shaderListDict)
            }
        }
    }
}

public class NodeGraphData: NSObject
{
    var singleNodes : Set<NodeData> = []
    private var indexNodeDataDict : Dictionary<String,NodeData> = [:]
    let updateDictOperation : UpdateDictOperation = UpdateDictOperation()
    let updateDictOperationQuene : OperationQueue = OperationQueue()
    
    public override init()
    {
        super.init()
        updateIndexNodeDataDict()
    }
    
    func getNodesTotalCount() -> Int
    {
        return indexNodeDataDict.count
    }
    
    func getNode(index: String) -> NodeData?
    {
        return indexNodeDataDict[index]
    }
    
    func addNode(node: NodeData) -> Bool
    {
        node.index = NSNumber(integerLiteral: getNodesTotalCount()).stringValue
        singleNodes.insert(node)
        updateIndexNodeDataDict()
        return true
    }
    
    func removeNode(node: NodeData) -> Bool
    {
        if singleNodes.contains(node)
        {
            self.singleNodes.remove(node)
        }
        for portData : NodePortData in node.inPorts
        {
            for connectionData : NodeConnectionData in portData.connections
            {
                let connectedNodeData : NodeData! = connectionData.inPort?.node
                if connectedNodeData != nil
                {
                    singleNodes.insert(connectedNodeData)
                }
            }
        }
        node.breakAllConnections()
        updateIndexNodeDataDict()
        return true
    }
    
    func canConnectNodeOutPort(outPort:NodePortData, inPort:NodePortData) -> Bool
    {
        let can : Bool = (outPort.isOutPortRelativeToNode() &&
            inPort.isInPortRelativeToNode() &&
            outPort.connections.count == 0 &&
            outPort.node?.index != inPort.node?.index &&
            outPort.requiredType.defaultCGType == inPort.requiredType.defaultCGType)
        
        return can
    }
    
    func connectNodeOutPort(outPort:NodePortData, inPort:NodePortData) -> Bool
    {
        let nodeConnection : NodeConnectionData = NodeConnectionData()
        nodeConnection.inPort = outPort
        nodeConnection.outPort = inPort
        
        inPort.connections.insert(nodeConnection)
        outPort.connections.insert(nodeConnection)
        
        if (singleNodes.contains(outPort.node!))
        {
            singleNodes.remove(outPort.node!)
        }
        updateIndexNodeDataDict()
        return true
    }
    
    func breakConnection(connection:NodeConnectionData) -> Bool
    {
        connection.inPort.connections.remove(connection)
        connection.outPort.connections.remove(connection)
        singleNodes.insert(connection.inPort.node!)
        updateIndexNodeDataDict()
        return true
    }
    
    private func updateIndexNodeDataDict() -> Void
    {
        if (updateDictOperation.isExecuting)
        {
            updateDictOperation.cancel()
        }
        updateDictOperation.singleNodes = singleNodes
        updateDictOperation.completionBlock = {
            self.indexNodeDataDict = self.updateDictOperation.outDict
        }
        updateDictOperationQuene.addOperation(updateDictOperation)
    }
}
//
//  NodeGraphDrawRectView.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 12/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import Foundation
import UIKit

public class NodeGraphDrawRectView: UIView
{
    weak var nodeGraphView : NodeGraphView?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.postInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.postInit()
    }
    
    init(frame: CGRect, nodeGraphView: NodeGraphView)
    {
        super.init(frame: frame)
        self.nodeGraphView = nodeGraphView
        self.postInit()
    }
    
    func postInit() -> Void
    {
        isUserInteractionEnabled = true
        isOpaque = false
        backgroundColor = UIColor.clear
    }
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?
    {
        setNeedsDisplay()
        return nil
    }
    
    override public func draw(_ rect: CGRect)
    {
        
    }
    
    func reloadData() -> Void {
        
    }
}
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
//
//  NodeGraphView.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 12/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import Foundation
import UIKit

public protocol NodeGraphViewDelegate: AnyObject
{
    func nodeGraphView(nodeGraphView: NodeGraphView, frameForNodeWithIndex: String) -> CGRect
    func nodeGraphView(nodeGraphView: NodeGraphView, didSelectNodeWithIndex: String)
}

public protocol NodeGraphViewDataSource: AnyObject
{
    func nodeGraphView(nodeGraphView: NodeGraphView, nodeWithIndex: String) -> NodeView?
    func numberOfNodes(in: NodeGraphView) -> Int
    func requiredViewController() -> UIViewController
}

public class NodeGraphView: UIView, NodeGraphContainerViewDelegate
{
    
    var containerView : NodeGraphContainerView?
    var drawRectView : NodeGraphDrawRectView?
    weak var delegate: NodeGraphViewDelegate?
    weak var dataSource: NodeGraphViewDataSource?
    weak var parentScrollView: NodeGraphScrollView?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.postInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.postInit()
    }
    
    init(frame: CGRect, parentScrollView: NodeGraphScrollView)
    {
        super.init(frame: frame)
        self.parentScrollView = parentScrollView
        self.postInit()
    }
    
    func postInit() -> Void
    {
        containerView = NodeGraphContainerView(frame: self.bounds, nodeGraphView:self)
        if let containerView = containerView
        {
            self.addSubview(containerView)
            containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            containerView.delegate = self
        }
        
        drawRectView = NodeGraphDrawRectView(frame: self.bounds, nodeGraphView:self)
        if let drawRectView = drawRectView
        {
            self.addSubview(drawRectView)
            drawRectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    
    func reloadData() -> Void
    {
        guard let containerView = containerView else
        {
            return
        }
        containerView.reloadData()
        
        guard let drawRectView = drawRectView else
        {
            return
        }
        drawRectView.reloadData()
    }
    
    public func nodeMoved(nodeGraphContainerView: NodeGraphContainerView) {
        if nodeGraphContainerView == self.containerView
        {
            self.drawRectView!.setNeedsDisplay()
        }
    }
    
    public func showNodeList(nodeGraphContainerView: NodeGraphContainerView, location: CGPoint)
    {
        let nodeListViewController : NodeListTableViewController = NodeListTableViewController()
        let nodeListNaviController : UINavigationController = UINavigationController(rootViewController: nodeListViewController)
        nodeListNaviController.modalPresentationStyle = .popover
        
        if let popoverViewController : UIPopoverPresentationController = nodeListNaviController.popoverPresentationController
        {
            popoverViewController.sourceRect = CGRect.init(origin: location, size: CGSize.init(width: 1, height: 1))
            popoverViewController.sourceView = nodeGraphContainerView
            popoverViewController.delegate = nodeListViewController;
            self.dataSource?.requiredViewController().present(nodeListNaviController, animated: true, completion: {})
        }
    }
}
//
//  NodeListTableViewController.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 15/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import UIKit

public class NodeListTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate
{
    var tableViewDataSource : Array<AnyClass> = []
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = "Add a node"
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            
            self.tableViewDataSource = NodeData.directSubclasses()
            
            DispatchQueue.main.async {
                print("This is run on the main queue, after the previous code in outer block")
                self.tableView.reloadData()
            }
        }
        
        
    }
    
    // MARK: - Table view data source
    
    override public func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tableViewDataSource.count
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let nodeSubclass: NodeData.Type = tableViewDataSource[indexPath.row] as! NodeData.Type
        cell.textLabel?.text = nodeSubclass.defaultTitle
        return cell
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    private func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
//
//  NodePortData.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 12/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import Foundation

public class NodePortData: NSObject
{
    weak var node : NodeData? = nil
    
    class var defaultTitle : String { return "" }
    class var defaultRequiredType : CGData.Type { return CGData.self }
    
    var index : String = ""
    var title : String = defaultTitle
    var connections : Set<NodeConnectionData> = []
    var requiredType : CGData.Type = defaultRequiredType
    
    func getPortDefaultValueExpression() -> String
    {
        return requiredType.defaultCGType + " " + getPortVariableName() + " = " + requiredType.defaultCGValue
    }
    
    func getPortVariableName() -> String
    {
        return "var_\(index)"
    }
    
    func breakAllConnections() -> Void
    {
        for connection in connections
        {
            if connection.inPort != self
            {
                connection.inPort.connections.remove(connection)
            }
            if connection.outPort != self
            {
                connection.outPort.connections.remove(connection)
            }
        }
    }
    
    func isInPortRelativeToNode() -> Bool
    {
        guard let node = node else { return false }
        return node.inPorts.contains(self)
    }
    
    func isOutPortRelativeToNode() -> Bool
    {
        guard let node = node else { return false }
        return node.outPorts.contains(self)
    }
    
    func isInPortRelativeToConnection() -> Bool
    {
        return isOutPortRelativeToNode()
    }
    
    func isOutPortRelativeToConnection() -> Bool
    {
        return isInPortRelativeToNode()
    }
}
//
//  NodePortKnotView.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 15/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import UIKit

public class NodePortKnotView: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
//
//  NodePortView.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 15/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import UIKit

public class NodePortView: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
//
//  NodeView.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 12/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import Foundation
import UIKit

public class NodeView: UIView
{
    weak var data : NodeData?
}


// MARK: - Intro
var controller : NodeEditorViewController = NodeEditorViewController()
var naviController : UINavigationController = UINavigationController(rootViewController: controller)
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = naviController
