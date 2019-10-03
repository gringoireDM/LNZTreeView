//
//  LNZTreeView.swift
//  PFRPG rd
//
//  Created by Giuseppe Lanza on 23/09/2017.
//  Copyright © 2017 Giuseppe Lanza. All rights reserved.
//

import UIKit

@objc public protocol TreeNodeProtocol {
    var identifier: String { get }
    var isExpandable: Bool { get }
}

@IBDesignable @objcMembers
public class LNZTreeView: UIView {
    class MinimalTreeNode {
        var identifier: String
        var indentationLevel: Int = 0
        
        var isExpandable: Bool = false
        var isExpanded: Bool = false
        
        
        var parent: TreeNodeProtocol?
        
        init(identifier: String) {
            self.identifier = identifier
        }
    }
    

        
    @IBInspectable public var indentationWidth: CGFloat = 10
    @IBInspectable public var isEditing: Bool {
        get { return tableView.isEditing }
        set { tableView.isEditing = newValue }
    }
    
    @IBInspectable public var rowHeight: CGFloat {
        get { return tableView.rowHeight }
        set { tableView.rowHeight = newValue }
    }
    
    @IBInspectable public var allowsSelectionDuringEditing: Bool {
        get { return tableView.allowsSelectionDuringEditing }
        set { tableView.allowsSelectionDuringEditing = newValue }
    }
    
    public func setEditing(_ editing: Bool, animated: Bool) {
        tableView.setEditing(editing, animated: animated)
    }

    lazy var tableView: UITableView! = {
        return UITableView(frame: frame, style: .plain)
    }()
    
    public var keyboardDismissMode : UIScrollView.KeyboardDismissMode {
        get {
            return tableView.keyboardDismissMode
        }
        set{
            tableView.keyboardDismissMode = newValue
        }
    }
    
    public var tableViewRowAnimation: UITableView.RowAnimation = .right

    var nodesForSection = [Int: [MinimalTreeNode]]()
    
    @IBOutlet public weak var dataSource: LNZTreeViewDataSource?
    @IBOutlet public weak var delegate: LNZTreeViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    private func commonInit() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        
        if #available(iOS 11.0, *) {
            let margins = safeAreaLayoutGuide
            tableView.leftAnchor.constraint(equalTo: margins.leftAnchor).isActive = true
            tableView.rightAnchor.constraint(equalTo: margins.rightAnchor).isActive = true
            tableView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
            tableView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        } else {
            addConstraints([
                NSLayoutConstraint(item: tableView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: tableView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: tableView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0)
                ])
        }
    }

    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()

        tableView.reloadData()
    }
    
    /**
     All the tree hierarchy will be lost and the dataSource will be reloaded from scratch.
     */
    public func resetTree() {
        nodesForSection.removeAll()
        
        tableView.reloadData()
    }
    
    /**
     This method returns the number of sections for the current load in dataSource.
     - returns: The number of sections.
     */
    public func numberOfSections() -> Int {
        return tableView.numberOfSections
    }
    
    /**
     The number of total rows in a given section. This method returns the complete number regardless of the
     elements level in the tree.
     - parameter section: The index of the section of which you are requesting the number of rows.
     - returns: The number of nodes in the section.
     */
    public func numberOfTotalNodesInSection(_ section: Int) -> Int {
        return nodesForSection[section]?.count ?? 0
    }
    
    /**
     The number of nodes in a given section, for nodes having as parent a given node. This method returns just
     the number of children, and just if the node is expanded, otherwise it will return 0.
     - parameter section: The index of the section of which you are requesting the number of rows.
     - parameter parent: The parent node you want the children count displayed in treeView.
     */
    public func numberOfNodesForSection(_ section: Int, inParent parent: TreeNodeProtocol?) -> Int {
        return nodesForSection[section]?.filter( { parent?.identifier == $0.parent?.identifier }).count ?? 0
    }
    
    private func toggleExpanded(_ toggle: Bool, node: TreeNodeProtocol, inSection section: Int) -> Bool {
        guard node.isExpandable,
            let nodes = nodesForSection[section],
            let indexPath = indexPathForNode(node, inSection: section) else {
                return false
        }
        
        let minimalNode = nodes[indexPath.row]
        guard minimalNode.isExpanded != toggle else { return true }
        tableView(tableView, didSelectRowAt: indexPath)
        return minimalNode.isExpanded == toggle
    }
    
    /**
     Programmatically expand an expandable node. The return of this method indicates if the node was expanded.
     - parameter node: The node to be expanded.
     - parameter section: The index of the section where the node is.
     - returns: true if the node was successfully expanded, false otherwise.
     */
    @discardableResult
    public func expand(node: TreeNodeProtocol, inSection section: Int) -> Bool {
        return toggleExpanded(true, node: node, inSection: section)
    }
    
    /**
     Programmatically collapse an expanded expandable node. The return of this method indicates if the node
     was collapsed.
     - parameter node: The node to be collapsed.
     - parameter section: The section index where the node is.
     - returns: true if the node was successfully collapsed, false otherwise.
     */
    @discardableResult
    public func collapse(node: TreeNodeProtocol, inSection section: Int) -> Bool {
        return toggleExpanded(false, node: node, inSection: section)
    }
    
    /**
     Programmatically select a node. If the node is expandable, the expand toggle will be triggered, which means
     that if it is expanded it will be collapsed, viceversa if it is collapsed it will be expanded.
     - parameter node: The node to be selected.
     - parameter section: The section index where the node is.
     - parameter animated: An animation will occur on select.
     - parameter scrollPosition: the scroll position for the selected node.
     - returns: true if the node was successfully selected. False otherwise.
     */
    @discardableResult
    public func select(node: TreeNodeProtocol, inSection section: Int, animated: Bool = false, scrollPosition: UITableView.ScrollPosition = .none) -> Bool {
        guard let indexPath = indexPathForNode(node, inSection: section) else { return false }
        tableView.selectRow(at: indexPath, animated: animated, scrollPosition: scrollPosition)
        tableView(tableView, didSelectRowAt: indexPath)
        return true
    }
    
    /**
     Retrieve the index path for a given node in a given section.
     */
    private func indexPathForNode(_ node: TreeNodeProtocol, inSection section: Int) -> IndexPath? {
        return indexPathForNode(withIdentifier: node.identifier, inSection: section)
    }
    
    private func indexPathForNode(withIdentifier identifier: String, inSection section: Int) -> IndexPath? {
        guard let nodes = nodesForSection[section],
            let nodeIndex = nodes.index(where: { $0.identifier == identifier }) else {
                return nil
        }
        return IndexPath(row: nodeIndex, section: section)
    }
    
    //MARK: Cells Reusability
    
    /**
     Register a class for the cell to use to instanciate any new cell for a given identifier.
     
     - parameter cellClass: The class of a cell that you want to use in the table.
     - parameter identifier: The reuse identifier for the cell. This parameter must not be nil and must not be an empty string.
     */
    @objc(registerCellClass:forCellReuseIdentifier:)
    public func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
        tableView.register(cellClass, forCellReuseIdentifier: identifier)
    }
    
    /**
     Registers a nib object containing a cell with the table view under a specified identifier.
     
     - parameter nib: A nib object that specifies the nib file to use to create the cell.
     - parameter identifier: The reuse identifier for the cell. This parameter must not be nil and must not be an empty string.
     */
    @objc(registerNib:forCellReuseIdentifier:)
    public func register(_ nib: UINib?, forCellReuseIdentifier identifier: String) {
        tableView.register(nib, forCellReuseIdentifier: identifier)
    }
    
    /**
     Returns a reusable table-view cell object for the specified reuse identifier and adds it to the table.
     ###Important
     You must register a class or nib file using the register(_:forCellReuseIdentifier:) or register(_:forCellReuseIdentifier:) method before calling this method.
     If you registered a class for the specified identifier and a new cell must be created, this method initializes the cell by calling its init(style:reuseIdentifier:) method. For nib-based cells, this method loads the cell object from the provided nib file. If an existing cell was available for reuse, this method calls the cell’s prepareForReuse() method instead.
     - parameter identifier: A string identifying the cell object to be reused. This parameter must not be nil.
     - parameter indexPath: The index path specifying the location of the cell. The data source receives this information when it is asked for the cell and should just pass it along. This method uses the index path to perform additional configuration based on the cell’s position in the table view.
     */
    public func dequeueReusableCell(withIdentifier identifier: String, for node: TreeNodeProtocol, inSection section: Int) -> UITableViewCell {
        let indexPath = indexPathForNode(node, inSection: section)!
        return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }
    
    public func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier:identifier)
    }
    
    /**
     Set the scroll position to match the position of the current node in the TreeView.
     - parameter node: The node to scroll to.
     - parameter section: The section index where the node is.
     - parameter scrollPosition: The scroll position.
     - parameter animated: This parameter indicates if the scroll must be animated.
     */
    public func scrollToNode(_ node: TreeNodeProtocol, inSection section: Int, scrollPosition: UITableView.ScrollPosition = .middle, animated: Bool = true) {
        guard let indexPath = indexPathForNode(node, inSection: section) else { return }
        tableView.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
    }
    
    /**
     Return the current node for the current selected row.
     
     - returns: The current node for the selected row, or nil if no row was selected
     */
    public func nodeForSelectedRow() -> TreeNodeProtocol? {
        guard let indexPath = tableView.indexPathForSelectedRow,
            let node = nodesForSection[indexPath.section]?[indexPath.row],
            let index = indexInParent(forNodeAt: indexPath),
            let dataSource = dataSource else {
            return nil
        }
        
        return dataSource.treeView(self, nodeForRowAt: index, forParentNode: node.parent)
    }
    
    /**
     Query the treeView to know if the node in parameter is expanded or not.
     
     - parameter node: The node you want to know the state.
     - parameter section: The section where the node is.
     
     - returns: Boolean value indicating if the node is expanded or not.
     */
    public func isExpanded(node: TreeNodeProtocol, forSection section: Int) -> Bool {
        guard node.isExpandable,
            let nodes = nodesForSection[section],
            let treeNode = nodes.first(where: { $0.identifier == node.identifier }) else { return false }
        return treeNode.isExpanded
    }
    
    /**
     Insert a node at an indexPath in a parentNode. The indexPath must be relative to the new node's
     parent node passed in parameter. Your data source must be up to date to reflect this change
     immediately.
     
     - parameter indexPath: The index path where to insert the new row, relative to its parentNode.
     - parameter parentNode: The parent node where to insert the new row. If the parent is not expanded,
     the row will not be inserted visually. If the parentNode is nil, then the root will be considered.
     */
    public func insertNode(at indexPath: IndexPath, inParent parentNode: TreeNodeProtocol?) {
        let section = indexPath.section
        guard let fullNewNode = dataSource?.treeView(self, nodeForRowAt: indexPath, forParentNode: parentNode),
            let realIndexPath = indexPathForNewNode(at: indexPath, in: parentNode),
            let indentationLevel = indentationLevelForChildren(inSection: section, of: parentNode) else { return }
        
        let newNode = MinimalTreeNode(identifier: fullNewNode.identifier)
        newNode.isExpandable = fullNewNode.isExpandable
        newNode.indentationLevel = indentationLevel
        newNode.parent = parentNode

        nodesForSection[indexPath.section]?.insert(newNode, at: realIndexPath.item)
        tableView.insertRows(at: [realIndexPath], with: .right)
    }
    
    /**
     This method will remove a node from the tree having the identifier passed in parameter in a given
     section. If the node is children of a not expanded parent, then the node will be deleted but no visual
     effect will be performed. If the node is a parent itself, all the children will be removed from the tree.
     
     - parameter identifier: The identifier of the node you want to remove from the tree.
     - parameter section: The section where the node exists.
     */
    public func removeNode(withIdentifier identifier: String, inSection section: Int) {
        guard let indexPath = indexPathForNode(withIdentifier: identifier, inSection: section),
            var nodes = nodesForSection[section] else { return }
        
        var indexPaths = [indexPath]
        let minimalNode = nodes[indexPath.row]

        if minimalNode.isExpandable {
            if let range = closeNode(minimalNode, atIndex: indexPath.row, in: &nodes) {
                indexPaths += range.map { IndexPath(row: $0, section: section) }
            }
            nodesForSection[section] = nodes
        }
        
        nodesForSection[section]?.remove(at: indexPath.row)
        tableView.deleteRows(at: indexPaths, with: .right)
    }
    
    private func indentationLevelForChildren(inSection section: Int, of parent: TreeNodeProtocol?) -> Int? {
        var indentationLevel = 0
        if let parent = parent {
            guard parent.isExpandable,
                let parentIndexPath = indexPathForNode(parent, inSection: section),
                let minimalParentNode = nodesForSection[parentIndexPath.section]?[parentIndexPath.row] else { return nil }
            
            indentationLevel = minimalParentNode.indentationLevel + 1
        }
        return indentationLevel
    }
    
    private func indexPathForNewNode(at indexPath: IndexPath, in parent: TreeNodeProtocol?) -> IndexPath? {
        var indentationLevel = 0
        var realIndexPath = IndexPath(row: 0, section: indexPath.section)
        if let parent = parent {
            guard parent.isExpandable,
                let parentIndexPath = indexPathForNode(parent, inSection: indexPath.section),
                let minimalParentNode = nodesForSection[parentIndexPath.section]?[parentIndexPath.row],
                minimalParentNode.isExpanded else { return nil }
            
            realIndexPath = parentIndexPath
            indentationLevel = minimalParentNode.indentationLevel + 1
        }
        
        let targetIndex = realIndexPath.item + indexPath.item
        var currentIndex = realIndexPath.item
        while currentIndex < targetIndex {
            guard let node = nodesForSection[indexPath.section]?[currentIndex] else { return nil }
            guard node.indentationLevel == indentationLevel else {
                guard node.indentationLevel > indentationLevel else { break }
                continue
            }
            
            currentIndex += 1
            realIndexPath.item += 1
        }
        
        return realIndexPath
    }
}

//MARK: - UITableViewDataSource
extension LNZTreeView: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.numberOfSections(in: self) ?? 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let rows = nodesForSection[section]?.count else {
            let rows = dataSource?.treeView(self, numberOfRowsInSection: section, forParentNode: nil) ?? 0
            
            var nodes = [MinimalTreeNode]()
            for i in 0..<rows {
                guard let fullNode = dataSource?.treeView(self, nodeForRowAt: IndexPath(row: i, section: section), forParentNode: nil) else {
                    fatalError("invalid dataSource for treeView: \(self)")
                }
                let node = MinimalTreeNode(identifier: fullNode.identifier)
                node.isExpandable = fullNode.isExpandable

                nodes.append(node)
                nodesForSection[section] = nodes
            }
            
            return rows
        }
        return rows
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let node = nodesForSection[indexPath.section]?[indexPath.row],
            let index = indexInParent(forNodeAt: indexPath) else {
            fatalError("Something wrong here")
        }
        
        //The logic of this view guarantees that if the node is a child, its parent will be not nil even if this is a placeholder.
        guard let cell = dataSource?.treeView(self, cellForRowAt: index, forParentNode: node.parent, isExpanded: node.isExpanded) else {
            fatalError("invalid dataSource for treeView: \(self)")
        }
        cell.indentationWidth = indentationWidth
        cell.indentationLevel = 2*node.indentationLevel
        
        return cell
    }
    
    private func indexInParent(forNodeAt indexPath: IndexPath) -> IndexPath? {
        guard let nodes = nodesForSection[indexPath.section] else { return nil }
        
        let node = nodes[indexPath.row]
        guard let index = nodes.filter({ node.parent?.identifier == $0.parent?.identifier })
            .index(where: { node.identifier == $0.identifier }) else { return nil }
        return IndexPath(row: index, section: indexPath.section)
    }
}

//MARK: - UITableViewDelegate
extension LNZTreeView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let nodes = nodesForSection[indexPath.section],
            let indexInParent = self.indexInParent(forNodeAt: indexPath) else {
                fatalError("Something wrong here")
        }
        let node = nodes[indexPath.row]
        
        return delegate?.treeView?(self, heightForNodeAt: indexInParent, forParentNode: node.parent) ?? tableView.rowHeight
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let nodes = nodesForSection[indexPath.section],
            let indexInParent = self.indexInParent(forNodeAt: indexPath) else {
                fatalError("Something wrong here")
        }
        let node = nodes[indexPath.row]

        return delegate?.treeView?(self, canEditRowAt: indexInParent, forParentNode: node.parent) ?? false
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard var nodes = nodesForSection[indexPath.section],
            let indexInParent = self.indexInParent(forNodeAt: indexPath) else {
                fatalError("Something wrong here")
        }
        let node = nodes[indexPath.row]
        delegate?.treeView?(self, commitDeleteForRowAt: indexInParent, forParentNode: node.parent)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard var nodes = nodesForSection[indexPath.section],
            let indexInParent = self.indexInParent(forNodeAt: indexPath) else {
            fatalError("Something wrong here")
        }
        let node = nodes[indexPath.row]
        
        guard node.isExpandable else {
            delegate?.treeView?(self, didSelectNodeAt: indexInParent, forParentNode: node.parent)
            return
        }
        CATransaction.begin()
        tableView.beginUpdates()
        defer {
            CATransaction.commit()
            tableView.endUpdates()
        }
        
        tableView.reloadRows(at: [indexPath], with: .fade)
        
        if node.isExpanded {
            let range = closeNode(node, atIndex: indexPath.row, in: &nodes)
            nodesForSection[indexPath.section] = nodes
            
            if let deleteRange = range {
                //Updating the tableView
                let indexPaths = Array(deleteRange).map { IndexPath(row: $0, section: indexPath.section) }
                tableView.deleteRows(at: indexPaths, with: tableViewRowAnimation)
            }
            CATransaction.setCompletionBlock {[weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.treeView?(strongSelf, didCollapseNodeAt: indexInParent, forParentNode: node.parent)
            }
        } else {
            let range = expandNode(node, at: indexPath, in: &nodes)
            nodesForSection[indexPath.section] = nodes
            
            if let insertRange = range {
                //Updating the tableView
                let indexPaths = Array(insertRange).map { IndexPath(row: $0, section: indexPath.section) }
                tableView.insertRows(at: indexPaths, with: tableViewRowAnimation)
            }
            CATransaction.setCompletionBlock {[weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.treeView?(strongSelf, didExpandNodeAt: indexInParent, forParentNode: node.parent)
            }
        }
    }
    
    private func expandNode(_ node: MinimalTreeNode, at indexPath: IndexPath, in nodes: inout [MinimalTreeNode]) -> CountableClosedRange<Int>? {
        defer { node.isExpanded = true }
        guard let index = indexInParent(forNodeAt: indexPath),
            let fullNode = dataSource?.treeView(self, nodeForRowAt: index, forParentNode: node.parent) else {
            fatalError("invalid dataSource for treeView: \(self)")
        }

        let numberOfChildren = dataSource?.treeView(self, numberOfRowsInSection: indexPath.section, forParentNode: fullNode) ?? 0
        guard numberOfChildren > 0 else { return nil }
        var newNodes = [MinimalTreeNode]()
        for i in 0..<numberOfChildren {
            guard let fullNewNode = dataSource?.treeView(self, nodeForRowAt: IndexPath(row: i, section: indexPath.section), forParentNode: fullNode) else {
                fatalError("invalid dataSource for treeView: \(self)")
            }

            let newNode = MinimalTreeNode(identifier: fullNewNode.identifier)
            newNode.isExpandable = fullNewNode.isExpandable
            newNode.indentationLevel = node.indentationLevel + 1
            newNode.parent = fullNode
            newNodes.append(newNode)
        }
        
        nodes.insert(contentsOf: newNodes, at: indexPath.row+1)
        return indexPath.row+1...indexPath.row+numberOfChildren
    }
    
    private func closeNode(_ node: MinimalTreeNode, atIndex index: Int, in nodes: inout [MinimalTreeNode]) -> CountableClosedRange<Int>? {
        defer { node.isExpanded = false }
        
        guard index+1 < nodes.count else { return nil }
        
        //Updating the dataSource
        var nextNode = nodes[index + 1]
        var removedNodes = 0
        while nextNode.indentationLevel > node.indentationLevel {
            removedNodes += 1
            nodes.remove(at: index+1)
            guard index+1 < nodes.count else {
                //The array is over
                break
            }
            
            nextNode = nodes[index + 1]
        }
        
        guard removedNodes > 0 else { return nil }

        return index+1...index+removedNodes
    }
}
