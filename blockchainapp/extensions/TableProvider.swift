import UIKit

protocol StandartTableViewCell: class where Self: UITableViewCell {
    static var cellID: String {get}
    static func height(data: Any, width: CGFloat) -> CGFloat
    func fill(data: Any?)
    var event: ((String, [String: Any]?) -> Void)? {get set}
}

extension StandartTableViewCell {
    internal static var cellID: String {
        get {
            return "StandartCellID"
        }
    }
    
    static internal func height(data: Any, width: CGFloat) -> CGFloat {
        return 44.0
    }
    
    internal func fill(data: Any?) { self.textLabel?.text = "\(data ?? 0)" }
}

protocol TableDataProvider: class {
    var numberOfSections: Int {get}
    func rows(asSection section: Int) -> Int
    func data(indexPath: IndexPath) -> Any
}

extension TableDataProvider {
    var numberOfSections: Int {
        return 0
    }
    func rows(asSection section: Int) -> Int {
        return 0
    }
}

protocol TableCellProvider: class {
    func cellClass(indexPath: IndexPath) -> StandartTableViewCell.Type
    func config(cell: StandartTableViewCell)
    
    func view(table: UITableView, forSection: Int, isHeader: Bool) -> UIView?
    func height(table: UITableView, forSection: Int, isHeader: Bool) -> CGFloat
}

extension TableCellProvider {
    func view(table: UITableView, forSection: Int, isHeader: Bool) -> UIView? {
        return nil
    }
    
    func height(table: UITableView, forSection: Int, isHeader: Bool) -> CGFloat {
        return 0.01
    }
}

class TableProvider: NSObject, UITableViewDataSource, UITableViewDelegate {
    var dataProvider: TableDataProvider!
    var cellProvider: TableCellProvider!
    
    init(tableView: UITableView, dataProvider: TableDataProvider, cellProvider: TableCellProvider) {
        super.init()
        self.dataProvider = dataProvider
        self.cellProvider = cellProvider
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    var cellShowed: ((IndexPath) -> Void)?
    var cellEvent: ((_ indexPath: IndexPath, _ event: String, _ data: [String: Any]?) -> Void)?
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataProvider.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.rows(asSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellClass = cellProvider.cellClass(indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellClass.cellID, for: indexPath) as! StandartTableViewCell
        cell.fill(data: dataProvider.data(indexPath: indexPath))
        cell.event = {[weak self] (event, data) in
            self?.cellEvent?(indexPath, event, data)
        }
        self.cellProvider.config(cell: cell)
        return cell as! UITableViewCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellClass = cellProvider.cellClass(indexPath: indexPath)
        return cellClass.height(data: dataProvider.data(indexPath: indexPath), width: tableView.frame.width)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.cellEvent?(indexPath, "onSelected", nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.cellShowed?(indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.cellProvider.view(table: tableView, forSection: section, isHeader: true)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.cellProvider.view(table: tableView, forSection: section, isHeader: false)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.cellProvider.height(table: tableView, forSection: section, isHeader: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.cellProvider.height(table: tableView, forSection: section, isHeader: false)
    }
}
