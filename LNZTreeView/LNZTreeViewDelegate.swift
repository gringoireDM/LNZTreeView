//
//  LNZTreeViewDelegate.swift
//  PFRPG rd
//
//  Created by Giuseppe Lanza on 24/09/2017.
//  Copyright © 2017 Giuseppe Lanza. All rights reserved.
//

import Foundation

@objc public protocol LNZTreeViewDelegate {
    
    @objc optional func treeView(_ treeView: LNZTreeView, canEditRowAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) -> Bool

    @objc optional func treeView(_ treeView: LNZTreeView, commitDeleteForRowAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?)

    @objc optional func treeView(_ treeView: LNZTreeView, heightForNodeAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) -> CGFloat
    
    /**
     This method is called when a node is successfully expanded. The indexPath is relative to the
     *parentNode* parameter.
     
     ## Example:
     An *indexPath* with row **i** and section **j** in parentNode **A** means the **i**th child of parentNode in the
     section **j**. If not present parentNode, the requested node is the ith element in the root of the section **j**.

     - parameter treeView: The tree view on which the event was triggered.
     - parameter indexPath: The indexPath of the expanded node, relative to its *parentNode*.
     - parameter parentNode: The parentNode for the expanded node. If nil, root is to be intended.
     */
    @objc optional func treeView(_ treeView: LNZTreeView, didExpandNodeAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?)
    
    /**
     This method is called when a node is successfully collapsed. The indexPath is relative to the
     *parentNode* parameter.
     
     ## Example:
     An *indexPath* with row **i** and section **j** in parentNode **A** means the **i**th child of parentNode in the
     section **j**. If not present parentNode, the requested node is the ith element in the root of the section **j**.
     
     - parameter treeView: The tree view on which the event was triggered.
     - parameter indexPath: The indexPath of the collapsed node, relative to its *parentNode*.
     - parameter parentNode: The parentNode for the collapsed node. If nil, root is to be intended.
     */
    @objc optional func treeView(_ treeView: LNZTreeView, didCollapseNodeAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?)
    
    /**
     This method is called when a node is successfully selected. The indexPath is relative to the
     *parentNode* parameter.
     
     ## Example:
     An *indexPath* with row **i** and section **j** in parentNode **A** means the **i**th child of parentNode in the
     section **j**. If not present parentNode, the requested node is the ith element in the root of the section **j**.
     
     - parameter treeView: The tree view on which the event was triggered.
     - parameter indexPath: The indexPath of the selected node, relative to its *parentNode*.
     - parameter parentNode: The parentNode for the selected node. If nil, root is to be intended.
     */
    @objc optional func treeView(_ treeView: LNZTreeView, didSelectNodeAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?)
}
