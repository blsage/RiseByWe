//
//  Rise_by_WeApp.swift
//  Rise by We
//
//  Created by Benjamin Leonardo Sage on 6/23/21.
//

import SwiftUI

@main
struct Rise_by_WeApp: App {
    @StateObject var liftModel = ExerciseModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .accentColor(.orange)
                .environmentObject(liftModel)
        }
    }
}
