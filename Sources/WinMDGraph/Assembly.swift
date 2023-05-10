import WinMD

public class Assembly {
    private let database: Database
    private let tableRow: WinMD.Assembly

    internal init(database: Database, rowIndex: TableRowIndex<WinMD.Assembly>) {
        self.database = database
        self.tableRow = database.tables.assembly[rowIndex]
    }
}