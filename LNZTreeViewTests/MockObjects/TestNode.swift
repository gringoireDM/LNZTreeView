//
//  TestNode.swift
//  PFRPG rdTests
//
//  Created by Giuseppe Lanza on 24/09/2017.
//  Copyright © 2017 Giuseppe Lanza. All rights reserved.
//

import Foundation
@testable import LNZTreeView

protocol ExpandableNode: TreeNodeProtocol {
    var children: [ExpandableNode]? { get }
}

class TestNode: ExpandableNode, Equatable {
    static func ==(lhs: TestNode, rhs: TestNode) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    var identifier: String
    var isExpandable: Bool
    var children: [ExpandableNode]?
    
    init(identifier: String, isExpandable: Bool, children: [ExpandableNode]?) {
        self.identifier = identifier
        self.isExpandable = isExpandable
        self.children = children
    }
}
