//
//  BookingDetailView.swift
//  StudentGarage1
//
//  Created by student on 10/13/24.
//


import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct BookingDetailView: View {
    let booking: Booking // The booking data passed to this view
    
    // MARK: - State Variables
    @State private var message: String = "" // Stores the message input
    @State private var showingAlert = false // Controls the display of the alert
    @State private var alertMessage: String = "" // Holds the content for the alert
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading) {
            
            // MARK: - Booking Details Section
            Text("Booking Details") // Title for the booking details
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom)
            
            // Display individual booking details
            Text("Name: \(booking.name)")
            Text("Address: \(booking.address)")
            Text("City: \(booking.city)")
            Text("Phone Number: \(booking.phoneNumber)")
            Text("Vehicle Make: \(booking.vehicleMake)")
            Text("Vehicle Model: \(booking.vehicleModel)")
            Text("Vehicle Year: \(booking.vehicleYear)")
            Text("VIN: \(booking.vinNumber)")
            Text("Mileage: \(booking.mileage)")
            Text("Complaint: \(booking.complaint)")
            Text("Date: \(booking.date)")
            
            // MARK: - Message Input Section
            TextField("Enter your message", text: $message) // Input field for message
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // MARK: - Send Message Button
            Button("Send Message") {
                sendMessage() // Trigger message sending
            }
            .padding()
            .alert(isPresented: $showingAlert) { // Display alert based on `showingAlert`
                Alert(
                    title: Text("Message Status"), // Title of the alert
                    message: Text(alertMessage), // Alert message content
                    dismissButton: .default(Text("OK")) // Dismiss button
                )
            }
            
            Spacer() // Adds space at the bottom of the view
        }
        .padding() // Adds padding around the view
        .navigationTitle("Booking Details") // Set the navigation title
        .navigationBarTitleDisplayMode(.inline) // Display title in inline mode
    }
    
    // MARK: - Send Message Function
    private func sendMessage() {
        // MARK: - Input Validation
        if message.isEmpty { // Check if the message field is empty
            alertMessage = "Please enter a message." // Set the alert message
            showingAlert = true // Show the alert
            return // Exit the function if no message is entered
        }
        
        // MARK: - Firestore Setup
        let db = Firestore.firestore() // Firestore database reference
        let messageData: [String: Any] = [ // Prepare the message data
            "bookingId": booking.id, // Booking ID
            "message": message, // Message content
            "timestamp": FieldValue.serverTimestamp() // Server timestamp(n Firestore is used to automatically add the current time (server-side) when the data is being saved to the Firestore database.)
        ]
        
        // MARK: - Save Message to Firestore
        db.collection("messages").addDocument(data: messageData) { error in // Add a document to the "messages" collection
            if let error = error { // Handle errors during the Firestore operation
                alertMessage = "Failed to send message: \(error.localizedDescription)" // Set alert message on failure
            } else { // On success
                alertMessage = "Message sent successfully!" // Set success message
                message = "" // Clear the message input
            }
            showingAlert = true // Show the alert regardless of the result
        }
    }
}
