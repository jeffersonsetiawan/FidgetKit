//
//  FidgetKitApp.swift
//  FidgetKit
//
//  Created by Jefferson Setiawan on 11/08/20.
//

import SwiftUI

@main
struct FidgetKitApp: App {
    @StateObject var state: AppState = AppState(fidgets: [.batman, .blue])
    var body: some Scene {
        WindowGroup {
            ContentView(state: state)
        }
    }
}
