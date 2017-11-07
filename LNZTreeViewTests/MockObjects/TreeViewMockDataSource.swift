//
//  TreeViewMockDataSource.swift
//  PFRPG rdTests
//
//  Created by Giuseppe Lanza on 24/09/2017.
//  Copyright © 2017 Giuseppe Lanza. All rights reserved.
//

import UIKit
@testable import LNZTreeView

class TreeViewMockDataSource<T: ExpandableNode>: LNZTreeViewDataSource {
    var roots: [[T]]!

    func numberOfSections(in treeView: LNZTreeView) -> Int {
        return roots.count
    }
    
    func treeView(_ treeView: LNZTreeView, numberOfRowsInSection section: Int, forParentNode parentNode: TreeNode?) -> Int {
        guard let parent = parentNode as? T else { return roots[section].count }
        return parent.children?.count ?? 0
    }
    
    func treeView(_ treeView: LNZTreeView, nodeForRowAt indexPath: IndexPath, forParentNode parentNode: TreeNode?) -> TreeNode {
        guard let parent = parentNode as? T else { return roots[indexPath.section][indexPath.row] }
        return parent.children![indexPath.row]
    }
    
    func treeView(_ treeView: LNZTreeView, cellForRowAt indexPath: IndexPath, forParentNode parentNode: TreeNode?, isExpanded: Bool) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
}
