//  Model
//  expenseRecord.swift
//  HW1-ExpenseTracking
//
//  Created by Duyen Vu on 2/22/24.
//

import Foundation

enum ExpenseCategory {
    case spending
    case savings
}

struct ActivitySummary: Identifiable, Equatable, Hashable {
    var id = UUID()
    var date: Date
    var category: ExpenseCategory
    var amount: Double
    var description: String
    
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}

struct expenseRecord {
    var id = UUID()
    var description: String
    var amount: Double
    var date: Date
    var category: ExpenseCategory
    
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    init(description: String, amount: Double, date: Date, category: ExpenseCategory) {
        self.description = description
        self.amount = amount
        self.date = date
        self.category = category
    }
    
    static func expensesWithinLastSevenDays(from expenses: [expenseRecord]) -> [expenseRecord] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return expenses.filter { $0.date > sevenDaysAgo }
    }
}

