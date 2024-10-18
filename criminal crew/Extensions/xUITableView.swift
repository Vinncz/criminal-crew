import UIKit

extension UITableView {
    
//    public func bindWithCustomCell<CellContent: UIView, Object: ObservableObject>(
//        to observedObject: Object, 
//        keyPath: KeyPath<Object, [String]>,
//        configureCell: @escaping (UITableViewCell, String) -> CellContent
//    ) -> (tableView: UITableView, delegate: CustomTableViewDelegate<CellContent>) {
//        
//        let items = observedObject[keyPath: keyPath]
//        let delegate = CustomTableViewDelegate(items: items, configureCell: configureCell)
//        
//        self.dataSource = delegate
//        self.delegate = delegate
//        
//        // Register basic UITableViewCell for reuse
//        self.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        
//        // Observing the changes in the ObservableObject
//        let _ = observedObject.objectWillChange.sink { [weak self] _ in
//            self?.reloadData()
//        }
//        
//        return (self, delegate)
//    }
    
}
