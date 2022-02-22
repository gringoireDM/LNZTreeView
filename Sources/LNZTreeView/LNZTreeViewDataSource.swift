//
//  LNZTreeViewDataSource.swift
//  PFRPG rd
//
//  Created by Giuseppe Lanza on 24/09/2017.
//  Copyright © 2017 Giuseppe Lanza. All rights reserved.
//

import UIKit

@objc public protocol LNZTreeViewDataSource: class {
    ///The tree view can be sectioned just like the UITableView
    func numberOfSections(in treeView: LNZTreeView) -> Int
    
    /**
     This method is indexed differently from a normal UITableView. The number of rows in a method call is
     dependant from the parent node parameter. If not nil, the parentNode indicates that treeView wants to
     know the number of children for the given parentNode, else the treeView is interested in root elements.
     
     - parameter treeView: The treeView asking for the number of rows.
     - parameter section: An index number identifying the section in treeView.
     - parameter parentNode: The TreeNode in which the treeView is interested in knowing its children count.
     If nil, the treeView is interested in the root for the section.
     
     - returns: An int value indicating the amount of nodes for a given parentNode
     */
    func treeView(_ treeView: LNZTreeView, numberOfRowsInSection section: Int, forParentNode parentNode: TreeNodeProtocol?) -> Int
    
    /**
     To avoid duplication, the treeView will ask as needed the node for a certain indexPath. The indexPath
     is relative to the requested node's parent node. The parent node is passed in parameters.
     
     ## Example:
     An *indexPath* with row **i** and section **j** in parentNode **A** means the **i**th child of parentNode in the
     section **j**. If not present parentNode, the requested node is the ith element in the root of the section **j**.
     
     - parameter treeView: The treeView asking for the node.
     - parameter indexPath: The indexPath of the requested node.
     - parameter parentNode: The parentNode of the requested node.
     
     - returns: The requested node.
     */
    func treeView(_ treeView: LNZTreeView, nodeForRowAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) -> TreeNodeProtocol
    
    /**
     This method has to return the cell for a given node at a certain indexPath. The indexPath
     is relative to the requested node's parent node. The parent node is passed in parameters.
     
     ## Example:
     An *indexPath* with row **i** and section **j** in parentNode **A** means the **i**th child of parentNode in the
     section **j**. If not present parentNode, the requested node is the ith element in the root of the section **j**.
     
     - parameter treeView: The treeView asking for the node.
     - parameter indexPath: The indexPath of the requested node.
     - parameter parentNode: The parentNode of the requested node.
     
     - returns: The cell for the node at *indexPath*.
     */
    func treeView(_ treeView: LNZTreeView, cellForRowAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?, isExpanded: Bool) -> UITableViewCell
}
