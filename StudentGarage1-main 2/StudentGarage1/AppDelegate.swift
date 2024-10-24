//
//  AppDelegate.swift
//  StudentGarage1
//
//  Created by student on 9/29/24.
//


import SwiftUI
import FirebaseCore

// MARK: - AppDelegate Class
// This class manages the application lifecycle and sets up initial configurations for the app.
class AppDelegate: NSObject, UIApplicationDelegate {
    
    // MARK: - Application Launch
    // This function is called when the application has completed launching.
    // It performs setup tasks and configurations necessary for the app to function properly.
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        // MARK: - Firebase Configuration
        // Configures Firebase services for the app, allowing access to Firebase features.
        FirebaseApp.configure()
        
        // Returning true indicates successful launch.
        return true
    }
}
