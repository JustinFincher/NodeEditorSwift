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
    let loadingIndicator : UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.alpha = 0.0
        self.title = "Add a node"
        view.backgroundColor = UIColor.white
        
        loadingIndicator.frame = CGRect.init(origin: CGPoint.init(x:
            (self.view.frame.size.width - loadingIndicator.frame.size.width)/2.0, y:
            (self.view.frame.size.height - loadingIndicator.frame.size.height)/2.0), size: loadingIndicator.frame.size)
        loadingIndicator.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
        self.view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        
        tableView.frame = self.view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        DispatchQueue.global(qos: .background).async
            {
                self.tableViewDataSource = NodeData.directSubclasses()
                DispatchQueue.main.async
                    {
                        self.tableView.reloadData()
                        UIView.animate(withDuration: 0.5, animations: {
                            self.tableView.alpha = 1.0
                        })
                }
        }
        
        
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
