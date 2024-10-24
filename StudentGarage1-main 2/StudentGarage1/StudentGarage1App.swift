//
//  StudentGarage1App.swift
//  StudentGarage1
//
//  Created by student on 9/29/24.
//

import SwiftUI

// MARK: - Main App Entry Point
// This struct defines the entry point for the StudentGarage1 application.
@main
struct StudentGarage1App: App {
    
    // MARK: - App Delegate
    // Using UIApplicationDelegateAdaptor to connect the AppDelegate for Firebase or other app-wide setups.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // MARK: - Scene
    // The main body of the app that defines the scene (or UI window) to be displayed when the app launches.
    var body: some Scene {
        WindowGroup {
            // MARK: - Initial View
            // The LoginView is the first view shown when the app launches, directing the user to log in.
            ContentView()
        }
    }
}
