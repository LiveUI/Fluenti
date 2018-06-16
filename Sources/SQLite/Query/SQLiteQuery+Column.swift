extension SQLiteQuery {
    public struct QualifiedColumnName {
        public var schema: String?
        public var table: String?
        public var name: ColumnName
        
        public init(schema: String? = nil, table: String? = nil, name: ColumnName) {
            self.schema = schema
            self.table = table
            self.name = name
        }
    }
    
    public struct ColumnName {
        public var string: String
        public init(_ string: String) {
            self.string = string
        }
    }
}

extension SQLiteQuery.QualifiedColumnName: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(name: .init(stringLiteral: value))
    }
}

extension SQLiteQuery.ColumnName: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension SQLiteSerializer {
    func serialize(_ columns: [SQLiteQuery.ColumnName]) -> String {
        return "(" + columns.map(serialize).joined(separator: ", ") + ")"
    }
    
    func serialize(_ column: SQLiteQuery.QualifiedColumnName) -> String {
        switch (column.schema, column.table) {
        case (.some(let schema), .some(let table)):
            return escapeString(schema) + "." + escapeString(table) + "." + serialize(column.name)
        case (.none, .some(let table)):
            return escapeString(table) + "." + serialize(column.name)
        default:
            return serialize(column.name)
        }
    }
    
    func serialize(_ column: SQLiteQuery.ColumnName) -> String {
        return escapeString(column.string)
    }
}
