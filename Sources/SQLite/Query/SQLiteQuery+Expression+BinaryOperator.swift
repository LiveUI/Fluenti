extension SQLiteQuery.Expression {
    public enum BinaryOperator {
        /// `||`
        case concatenate
        
        /// `*`
        case multiply
        
        /// `/`
        case divide
        
        /// `%`
        case modulo
        
        /// `+`
        case add
        
        /// `-`
        case subtract
        
        /// `<<`
        case bitwiseShiftLeft
        
        /// `>>`
        case bitwiseShiftRight
        
        /// `&`
        case bitwiseAnd
        
        /// `|`
        case bitwiseOr
        
        /// `<`
        case lessThan
        
        /// `<=`
        case lessThanOrEqual
        
        /// `>`
        case greaterThan
        
        /// `>=`
        case greaterThanOrEqual
        
        /// `=` or `==`
        case equal
        
        /// `!=` or `<>`
        case notEqual
        
        /// `AND`
        case and
        
        /// `OR`
        case or
    }
}

public func ==(_ lhs: SQLiteQuery.Expression, _ rhs: SQLiteQuery.Expression) -> SQLiteQuery.Expression {
    return .binary(lhs, .equal, rhs)
}

public func !=(_ lhs: SQLiteQuery.Expression, _ rhs: SQLiteQuery.Expression) -> SQLiteQuery.Expression {
    return .binary(lhs, .notEqual, rhs)
}

public func ||(_ lhs: SQLiteQuery.Expression, _ rhs: SQLiteQuery.Expression) -> SQLiteQuery.Expression {
    return .binary(lhs, .or, rhs)
}

public func &&(_ lhs: SQLiteQuery.Expression, _ rhs: SQLiteQuery.Expression) -> SQLiteQuery.Expression {
    return .binary(lhs, .and, rhs)
}

public func &=(_ lhs: inout SQLiteQuery.Expression?, _ rhs: SQLiteQuery.Expression) {
    if let l = lhs {
        lhs = l && rhs
    } else {
        lhs = rhs
    }
}

public func |=(_ lhs: inout SQLiteQuery.Expression?, _ rhs: SQLiteQuery.Expression) {
    if let l = lhs {
        lhs = l || rhs
    } else {
        lhs = rhs
    }
}

extension SQLiteSerializer {
    func serialize(_ expr: SQLiteQuery.Expression.BinaryOperator) -> String {
        switch expr {
        case .add: return "+"
        case .bitwiseAnd: return "&"
        case .bitwiseOr: return "|"
        case .bitwiseShiftLeft: return "<<"
        case .bitwiseShiftRight: return ">>"
        case .concatenate: return "||"
        case .divide: return "/"
        case .equal: return "="
        case .greaterThan: return ">"
        case .greaterThanOrEqual: return ">="
        case .lessThan: return "<"
        case .lessThanOrEqual: return "<="
        case .modulo: return "%"
        case .multiply: return "*"
        case .notEqual: return "!="
        case .subtract: return "-"
        case .and: return "AND"
        case .or: return "OR"
        }
    }
}
