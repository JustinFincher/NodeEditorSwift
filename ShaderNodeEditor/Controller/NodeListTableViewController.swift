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
        view.backgroundColor = UIColor.white
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
