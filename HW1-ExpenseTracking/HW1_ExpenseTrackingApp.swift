//
//  HW1_ExpenseTrackingApp.swift
//  HW1-ExpenseTracking
//
//  Created by Duyen Vu on 2/22/24.
//

import SwiftUI

@main
struct HW1_ExpenseTrackingApp: App {
    
    var body: some Scene {
        WindowGroup {
            let mockTrackingVM = trackingDictionary(expenses: [], threshold: 100.0)
            ContentView(trackingVM: mockTrackingVM)
        }
    }
}
