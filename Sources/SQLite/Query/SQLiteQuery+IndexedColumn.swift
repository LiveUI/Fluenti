extension SQLiteQuery {
    public struct IndexedColumns {
        public var columns: [IndexedColumn]
        public var predicate: Expression?
    }
    
    
    public struct IndexedColumn {
        public enum Value {
            case column(ColumnName)
            case expression(Expression)
        }
        public var value: Value
        public var collate: String?
        public var direction: Direction?
        
        public init(value: Value, collate: String? = nil, direction: Direction? = nil) {
            self.value = value
            self.collate = collate
            self.direction = direction
        }
    }
}

extension SQLiteSerializer {
    func serialize(_ indexed: SQLiteQuery.IndexedColumns, _ binds: inout [SQLiteData]) -> String {
        var sql: [String] = []
        sql.append("(" + indexed.columns.map { serialize($0, &binds) }.joined(separator: ", ") + ")")
        if let predicate = indexed.predicate {
            sql.append("WHERE")
            sql.append(serialize(predicate, &binds))
        }
        return sql.joined(separator: " ")
    }
    
    func serialize(_ column: SQLiteQuery.IndexedColumn, _ binds: inout [SQLiteData]) -> String {
        var sql: [String] = []
        switch column.value {
        case .column(let string): sql.append(serialize(string))
        case .expression(let expr): sql.append(serialize(expr, &binds))
        }
        if let collate = column.collate {
            sql.append("COLLATE")
            sql.append(collate)
        }
        if let direction = column.direction {
            sql.append(serialize(direction))
        }
        return sql.joined(separator: " ")
    }
}
