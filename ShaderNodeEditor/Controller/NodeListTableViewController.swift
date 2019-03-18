//
//  NodeListTableViewController.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 15/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import UIKit

public protocol NodeListTableViewControllerSelectDelegate: AnyObject
{
    func nodeClassSelected(controller: NodeListTableViewController, nodeDataClass : AnyClass, point: CGPoint) -> Void
}

public class NodeListTableViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITableViewDelegate, UITableViewDataSource
{
    weak var delegate : NodeListTableViewControllerSelectDelegate?
    var tableViewDataSource : Array<AnyClass> = []
    let tableView : UITableView = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = "Add a node"
        view.backgroundColor = UIColor.white
        
        tableView.frame = self.view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        tableViewDataSource = NodeInfoCacheManager.shared.getNodeClasses()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let selectedClass : AnyClass = self.tableViewDataSource[indexPath.row]
        if let popoverPresentationController : UIPopoverPresentationController = self.navigationController!.presentationController as? UIPopoverPresentationController
        {
            delegate?.nodeClassSelected(controller: self, nodeDataClass: selectedClass, point: popoverPresentationController.sourceRect.origin)
        }
        self.presentingViewController?.dismiss(animated: true, completion: {})
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tableViewDataSource.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        let nodeSubclass: NodeData.Type = tableViewDataSource[indexPath.row] as! NodeData.Type
        cell.textLabel?.text = nodeSubclass.defaultTitle
        return cell
    }
    
    
    // MARK: - UIPopoverPresentationControllerDelegate
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
