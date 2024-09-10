//
//  ContentView.swift
//  HW1-ExpenseTracking
//
//  Created by Duyen Vu on 2/22/24.
//

import SwiftUI
import SwiftUICharts

struct ContentView: View {
    @ObservedObject var trackingVM: trackingDictionary
    @State private var selectedCategory: ExpenseCategory = .spending

    @State private var description: String = ""
    @State private var amount: String = ""
    @State private var selectedDate: Date = Date()
    
    @State private var showActivitiesSummary = false
    @State private var showSpendingThresholdAlert = false
    @State private var showSavingThresholdAlert = false
    @State private var showWeeklyReport = false

    var body: some View {
        NavigationView {
        VStack {
        Spacer()
        
        ToolView(trackingVM: trackingVM)
        
        dataEnterView(trackingVM: trackingVM)
        
        NavigationLink(destination: ActivitiesSummaryView(trackingVM: trackingVM), isActive: $showActivitiesSummary) {
        EmptyView()
        }
        Button(action: {
        showActivitiesSummary = true
        }) {
        Text("Activities Summary")
        }
        .padding()
        
        NavigationLink(destination: BarChart(trackingVM: trackingVM), isActive: $showWeeklyReport) {
        EmptyView()
        }
        Button(action: {
        showWeeklyReport = true
        }) {
        Text("Spending & Earning Report")
        }
        .padding()
        
        Spacer()
        }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Expense Tracker")
        }
    
        .alert("Spending Threshold Reached for This Week! You Spent too Much!", isPresented: $showSpendingThresholdAlert) {
            Button("OK") {
               
            }
        }
    
        .alert("Saving Threshold Reached for This Week! You Save Some Good Money!", isPresented: $showSavingThresholdAlert) {
            Button("OK") {
            
            }
        }
        .onChange(of: trackingVM.calculateSpendingWeeklySum()) { spendingWeeklySum in
            if spendingWeeklySum >= trackingVM.threshold {
                showSpendingThresholdAlert = true
            }
        }
        .onChange(of: trackingVM.calculateSavingWeeklySum()) { savingWeeklySum in
            if savingWeeklySum >= trackingVM.threshold {
                showSavingThresholdAlert = true
            }
        }
    }
}

struct BarChart: View {
    var trackingVM: trackingDictionary

    var body: some View {
        let dailySpending = trackingVM.calculateDailySpending()
        let dailySaving = trackingVM.calculateDailySaving()
        let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

        let dailySpendingChartData = daysOfWeek.compactMap { day -> (String, Double)? in
            guard let spending = dailySpending[day] else { return nil }
            return (day, spending)
        }

        let dailySavingChartData = daysOfWeek.compactMap { day -> (String, Double)? in
            guard let saving = dailySaving[day] else { return nil }
            return (day, saving)
        }

        return ScrollView {
            Spacer()
            Spacer()
            Spacer()
            VStack(spacing: 30) {
                    HStack(spacing: 15) {
                            BarChartView(data: ChartData(values: dailySpendingChartData), title: "Spending Report", form: ChartForm.medium)
                             .padding()
                     }
                     HStack(spacing: 15) {
                           BarChartView(data: ChartData(values: dailySavingChartData), title: "Saving Report", form: ChartForm.medium)
                        .padding()
                }
            
                Text(spendingHabitDescription)
                    .font(.headline)
                    .padding()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Spending & Earning Report")
        }
    }

    private var spendingHabitDescription: String {
        if trackingVM.calculateSpendingWeeklySum() >= trackingVM.threshold {
            return "You spent too much!"
        } else if trackingVM.calculateSavingWeeklySum() >= trackingVM.threshold {
            return "You saved some good money!"
        } else {
            return "You have a normal budget now!"
        }
    }
}

struct ActivitiesSummaryView: View {
    @ObservedObject var trackingVM: trackingDictionary
    @State private var dataID: UUID?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(trackingVM.lastSevenDaysActivities) { activity in
                        VStack(alignment: .leading) {
                            Text("\(formattedDate(activity.date))")
                            Text("you \(activity.category == .spending ? "spent" : "saved") $\(activity.amount, specifier: "%.2f") on \(activity.description)")
                            Divider()
                        }
                        .padding()
                        .id(activity.id)
                    
                    }
                    Spacer()
                }
                .scrollPosition(id: $dataID)
                .onChange(of: trackingVM.lastSevenDaysActivities) { _ in
                    dataID = trackingVM.lastSevenDaysActivities.last?.id
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Activities Summary")
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct ToolView: View {
    @ObservedObject var trackingVM: trackingDictionary
    @State private var showingSetThresholdAlert = false
    @State private var showingInvalidInputAlert = false
    @State private var setThreshold: String = ""

    var body: some View {
        Text("")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showingSetThresholdAlert = true
                    }, label: {
                        Image(systemName: "gearshape")
                    })
                }
            }
            .alert("Set Threshold", isPresented: $showingSetThresholdAlert, actions: {
                TextField("Enter Threshold", text: $setThreshold)
                    .keyboardType(.decimalPad)

                Button("Set", action: {
                    if let threshold = Double(setThreshold) {
                        trackingVM.threshold = threshold
                    } else {
                        showingInvalidInputAlert = true
                    }

                    showingSetThresholdAlert = false
                })

                Button("Cancel", role: .cancel, action: {
                    showingSetThresholdAlert = false
                })
            }, message: {
                Text("Please enter the threshold amount that you want to spend/earn for this week.")
            })
            .alert("Invalid Input! Please enter a valid number.", isPresented: $showingInvalidInputAlert) {
                Text("Close")
            }
    }
}

struct dataEnterView: View {
    @ObservedObject var trackingVM: trackingDictionary
    @State private var description: String = ""
    @State private var amount: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedCategory: ExpenseCategory = .spending

    var body: some View {
        VStack(spacing: 30) {
            Text("Threshold: $\(trackingVM.threshold, specifier: "%.2f")")
                .font(.title)
                .padding(.leading)
                .bold()
                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
        
            TextField("Description", text: $description)
                .padding()
            TextField("Amount", text: $amount)
                .keyboardType(.decimalPad)
                .padding()
            DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                .padding()
            Picker("Category", selection: $selectedCategory) {
                Text("Spending").tag(ExpenseCategory.spending)
                Text("Savings").tag(ExpenseCategory.savings)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            Button("Add Expense", action: addExpense)
                .padding()
                .cornerRadius(100)
                .fontWeight(.bold)
                .foregroundColor(Color.blue)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2)
                    )
        }
        .padding()
        Spacer()
    }

    private func addExpense() {
        guard let amount = Double(amount) else {
            return
        }

        trackingVM.addExpense(description: description, amount: amount, date: selectedDate, category: selectedCategory)

        description = ""
        self.amount = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
    let mockTrackingVM = trackingDictionary(expenses: [], threshold: 100.0)

        return ContentView(trackingVM: mockTrackingVM)
    }
}

