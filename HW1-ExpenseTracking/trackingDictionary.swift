//  View Model
//  trackingDictionary.swift
//  HW1-ExpenseTracking
//
//  Created by Duyen Vu on 2/22/24.
//

import Foundation

class trackingDictionary: ObservableObject {
    @Published var expenses: [expenseRecord] = []
    @Published var threshold: Double = 0.0
    @Published var spending: Double = 0.0
    @Published var saving: Double = 0.0
    @Published var lastSevenDaysActivities: [ActivitySummary] = []
    @Published var overspentAlertShown: Bool = false
    @Published var savingsReachedAlertShown: Bool = false

    init(expenses: [expenseRecord], threshold: Double) {
        self.expenses = expenses
        self.threshold = threshold
        updateLastSevenDaysActivities()
    }

    func addExpense(description: String, amount: Double, date: Date, category: ExpenseCategory) {
        let newExpense = expenseRecord(description: description, amount: amount, date: date, category: category)
        expenses.append(newExpense)
        updateSpendingAndSaving()
        updateLastSevenDaysActivities()
    }

    private func updateLastSevenDaysActivities() {
        let expensesWithinLastSevenDays = expenseRecord.expensesWithinLastSevenDays(from: expenses)
        var activities: [ActivitySummary] = []

        for expense in expensesWithinLastSevenDays {
            let activity = ActivitySummary(
                date: expense.date,
                category: expense.category,
                amount: expense.amount,
                description: expense.description
            )
            activities.append(activity)
        }

        lastSevenDaysActivities = activities
    }
    
    private func updateSpendingAndSaving() {
        let spendingRecords = expenses.filter { $0.category == .spending }
        let savingRecords = expenses.filter { $0.category == .savings }
        
        spending = spendingRecords.reduce(0) { $0 + $1.amount }
        saving = savingRecords.reduce(0) { $0 + $1.amount }
    }
    
    func calculateSpendingWeeklySum() -> Double {
        let spendingRecords = expenses.filter { $0.category == .spending }
        let spendingExpensesWithinLastSevenDays = expenseRecord.expensesWithinLastSevenDays(from: spendingRecords)
        return spendingExpensesWithinLastSevenDays.reduce(0) { $0 + $1.amount }
    }
    
    func calculateSavingWeeklySum() -> Double {
        let savingRecords = expenses.filter { $0.category == .savings }
        let savingExpensesWithinLastSevenDays = expenseRecord.expensesWithinLastSevenDays(from: savingRecords)
        return savingExpensesWithinLastSevenDays.reduce(0) { $0 + $1.amount }
    }
    
    func calculateDailySpending() -> [String: Double] {
        let spendingRecords = expenses.filter { $0.category == .spending }
        let spendingByDay = Dictionary(grouping: spendingRecords, by: { $0.dayOfWeek })
        let dailySpending = spendingByDay.mapValues { $0.reduce(0) { $0 + $1.amount } }
        return dailySpending
    }

    func calculateDailySaving() -> [String: Double] {
        let savingRecords = expenses.filter { $0.category == .savings }
        let savingByDay = Dictionary(grouping: savingRecords, by: { $0.dayOfWeek })
        let dailySaving = savingByDay.mapValues { $0.reduce(0) { $0 + $1.amount } }
        return dailySaving
    }
}

