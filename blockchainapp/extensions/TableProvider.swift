import UIKit

class StandartTableViewCell: UITableViewCell {
    
    open static let cellID: String = "StandartCellID"
    
    static open func height(data: Any) -> CGFloat {
        return 44.0
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func initialize() { }
    
    open func fill(data: Any?) { self.textLabel?.text = "\(data ?? 0)" }
}

class CustomCell: StandartTableViewCell {
    
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
    func data(indexPath: IndexPath) -> Any? {
        return nil
    }
}

protocol TableCellProvider: class {
    func cellClass(indexPath: IndexPath) -> StandartTableViewCell.Type
    
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
    
    var cellShowed: ((IndexPath) -> Void)?
    
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellClass = cellProvider.cellClass(indexPath: indexPath)
        return cellClass.height(data: dataProvider.data(indexPath: indexPath))
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
