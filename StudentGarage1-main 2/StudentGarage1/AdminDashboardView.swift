//
//  AdminDashboardView.swift
//  StudentGarage1
//
//  Created by student on 10/7/24.
//


import SwiftUI 
import Firebase
import FirebaseAuth 


// Define the Booking struct to represent booking information
struct Booking: Identifiable, Hashable {
    let id: String // Unique identifier for each booking
    let name: String // Name of the person who made the booking
    let address: String // Address related to the booking
    let city: String // City related to the booking
    let phoneNumber: String // Contact phone number for the booking
    let vehicleMake: String // The make of the vehicle (e.g., Toyota, Ford)
    let vehicleModel: String // The model of the vehicle (e.g., Corolla, Mustang)
    let vehicleYear: String // The year of the vehicle's manufacture
    let vinNumber: String // The Vehicle Identification Number (VIN) for the vehicle
    let mileage: String // Mileage of the vehicle at the time of the booking
    let complaint: String // Description of the issue or service request
    let date: String // Date the booking was made
}

// Define the view for the admin dashboard
struct AdminDashboardView: View {
    @State private var bookings: [Booking] = [] // State variable to store fetched bookings
    @Environment(\.presentationMode) var presentationMode // Environment variable for managing view dismissal

    var body: some View {
        // NavigationView to enable navigation between views
        NavigationView {
            VStack { // Vertical stack to arrange UI elements
                // MARK: - Header
                Text("Admin Dashboard") // Display the title of the dashboard
                    .font(.largeTitle) // Set large font size
                    .fontWeight(.bold) // Make the text bold
                    .padding() // Add padding around the text

                // MARK: - Booking Submissions Section
                Section(header: Text("Booking Submissions").font(.headline)) { // Section header for the list
                    List(bookings) { booking in // Iterate through the list of bookings
                        NavigationLink(destination: BookingDetailView(booking: booking)) { // Link to detailed booking view
                            VStack(alignment: .leading) { // Align items to the left
                                Text("Name: \(booking.name)") // Display booking name
                                Text("Date: \(booking.date)") // Display booking date
                            }
                            .padding(.vertical) // Add vertical padding between items
                        }
                    }
                }
                .padding() // Add padding around the booking list

                Spacer() // Add space below the list to push it upwards
            }
            .onAppear(perform: fetchBookings) // Fetch bookings when the view appears
            .navigationTitle("Admin Dashboard") // Set the title of the navigation bar
            .navigationBarItems(trailing: Button(action: logout) { // Add logout button on the navigation bar
                Text("Logout") // Display "Logout" text
                    .foregroundColor(.red) // Set text color to red
            })
            .padding() // Add padding around the entire view
        }
    }

    // MARK: - Fetch Bookings from Firebase
    private func fetchBookings() {
        let db = Database.database().reference().child("bookings") // Reference the "bookings" node in Firebase Realtime Database
        
        db.observe(.value) { snapshot in // Observe changes in the "bookings" node
            var fetchedBookings: [Booking] = [] // Temporary array to hold fetched bookings
            
            for child in snapshot.children { // Iterate through each child in the snapshot
                if let snapshot = child as? DataSnapshot, // Cast child as DataSnapshot
                   let bookingData = snapshot.value as? [String: Any], // Extract booking data as a dictionary
                   let name = bookingData["name"] as? String, // Get the name from booking data
                   let address = bookingData["address"] as? String, // Get the address from booking data
                   let city = bookingData["city"] as? String, // Get the city from booking data
                   let phoneNumber = bookingData["phoneNumber"] as? String, // Get the phone number from booking data
                   let vehicleMake = bookingData["vehicleMake"] as? String, // Get the vehicle make
                   let vehicleModel = bookingData["vehicleModel"] as? String, // Get the vehicle model
                   let vehicleYear = bookingData["vehicleYear"] as? String, // Get the vehicle year
                   let vinNumber = bookingData["vinNumber"] as? String, // Get the VIN number
                   let mileage = bookingData["mileage"] as? String, // Get the mileage
                   let complaint = bookingData["complaint"] as? String, // Get the complaint description
                   let date = bookingData["date"] as? String { // Get the date of the booking
                    
                    let id = snapshot.key // Use the snapshot key as the booking ID
                    let booking = Booking(id: id, name: name, address: address, city: city, phoneNumber: phoneNumber, vehicleMake: vehicleMake, vehicleModel: vehicleModel, vehicleYear: vehicleYear, vinNumber: vinNumber, mileage: mileage, complaint: complaint, date: date) // Create a new Booking instance
                    
                    fetchedBookings.append(booking) // Add the new booking to the array
                }
            }
            
            self.bookings = fetchedBookings // Update the state with the fetched bookings
        }
    }

    // MARK: - Logout Functionality
    private func logout() {
        do {
            try Auth.auth().signOut() // Try to sign out the user
            presentationMode.wrappedValue.dismiss() // Dismiss the current view on successful sign-out
        } catch {
            print("Error signing out: \(error.localizedDescription)") // Print error if sign-out fails
        }
    }
}

#Preview { // SwiftUI preview code for testing the view
    AdminDashboardView() // Preview the AdminDashboardView
}
