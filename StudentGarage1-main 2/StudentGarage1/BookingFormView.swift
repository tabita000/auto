
//  BookingFormView.swift
//  StudentGarage1
//
//  Created by student on 9/29/24.
//

import SwiftUI
import Firebase

// MARK: - BookingFormView
// View responsible for displaying the booking form for a selected service date
struct BookingFormView: View {
    // MARK: - Properties
    let selectedDate: Date  // Date selected by the user for the booking
    
    // State variables for form fields
    @State private var name: String = ""
    @State private var address: String = ""
    @State private var city: String = ""
    @State private var phoneNumber: String = ""
    @State private var vehicleMake: String = ""
    @State private var vehicleModel: String = ""
    @State private var vehicleYear: String = ""
    @State private var vinNumber: String = ""
    @State private var mileage: String = ""
    @State private var complaint: String = ""
    
    // Alert handling state variables
    @State private var alertMessage: String = ""
    @State private var showingAlert = false
    @State private var isBookingSuccessful = false

    // MARK: - Body
    var body: some View {
        NavigationView {
            // MARK: - Form Layout
            Form {
                // MARK: - Customer Information Section
                Section(header: Text("Customer Information")) {
                    TextField("Name", text: $name)
                    TextField("Address", text: $address)
                    TextField("City", text: $city)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad) // Ensure correct keyboard type
                }
                
                // MARK: - Vehicle Information Section
                Section(header: Text("Vehicle Information")) {
                    TextField("Make", text: $vehicleMake)
                    TextField("Model", text: $vehicleModel)
                    TextField("Year", text: $vehicleYear)
                        .keyboardType(.numberPad) // Numerical keyboard for year
                    TextField("VIN#", text: $vinNumber)
                    TextField("Mileage", text: $mileage)
                        .keyboardType(.numberPad) // Numerical keyboard for mileage
                }
                
                // MARK: - Complaint Section
                Section(header: Text("Complaint")) {
                    TextField("Describe the issue", text: $complaint)
                }
                
                // MARK: - Submit Button Section
                Section {
                    Button("Submit Booking") {
                        validateAndSaveBooking() // Trigger form validation and save
                    }
                }
            }
            .navigationBarTitle("Book Service for \(formattedDate(selectedDate))") // Display selected date in the title
            .alert(isPresented: $showingAlert) {
                // Show alert for success or error messages
                Alert(
                    title: Text(isBookingSuccessful ? "Booking Confirmed" : "Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    // MARK: - Form Validation and Booking Submission

    // Validate the input fields and proceed with booking submission if valid
    private func validateAndSaveBooking() {
        // Check if any required field is empty
        if name.isEmpty || address.isEmpty || city.isEmpty || phoneNumber.isEmpty ||
           vehicleMake.isEmpty || vehicleModel.isEmpty || vehicleYear.isEmpty ||
           vinNumber.isEmpty || mileage.isEmpty || complaint.isEmpty {
            alertMessage = "Please fill in all fields."  // Show error if any field is empty
            isBookingSuccessful = false
            showingAlert = true
            return
        }
        
        // Validate phone number
        if !isValidPhoneNumber(phoneNumber) {
            alertMessage = "Please enter a valid phone number. Ex: 123 456-7890, (098) 765-4321"
            phoneNumber = "" //clear field
            isBookingSuccessful = false
            showingAlert = true
            return
        }

        // Validate vehicle year
        if !isValidVehicleYear(vehicleYear) {
            alertMessage = "Please enter a valid vehicle year between 1880 and current year."
            vehicleYear = "" //clear field
            isBookingSuccessful = false
            showingAlert = true
            return
        }
        
        // Check the vehicle year and apply VIN validation accordingly
        if let yearInt = Int(vehicleYear), yearInt > 1980 {
            // Validate VIN only if the year is greater than 1980
            if !isValidVIN(vinNumber) {
                alertMessage = "Please enter a valid VIN number. A VIN number should have 17 characters."
                vinNumber = "" //clear field
                isBookingSuccessful = false
                showingAlert = true
                return
            }
        } else {
            // If the year is 1980 or earlier, no validation is required for VIN
            if vinNumber.isEmpty {
                alertMessage = "VIN number cannot be empty."
                isBookingSuccessful = false
                showingAlert = true
                return
            }
        }
        
        // Validate mileage
        if !isValidMileage(mileage) {
            alertMessage = "Please enter a valid mileage. Must be a positive number."
            mileage = "" //clear field
            isBookingSuccessful = false
            showingAlert = true
            return
        }

        // Proceed to save the booking if validation passes
        saveBooking()
    }
    
    // MARK: - Validation Functions
    
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        let cleanedPhone = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        return cleanedPhone.count == 10
    }

    private func isValidVehicleYear(_ year: String) -> Bool {
        guard let yearInt = Int(year) else { return false }
        let currentYear = Calendar.current.component(.year, from: Date())
        return yearInt >= 1880 && yearInt <= currentYear // Valid range for vehicle year
    }

    private func isValidMileage(_ mileage: String) -> Bool {
        guard let mileageInt = Int(mileage) else { return false }
        return mileageInt >= 0 // Mileage should be non-negative
    }

    private func isValidVIN(_ vin: String) -> Bool {
        let vinRegex = "^[A-HJ-NPR-Z0-9]{17}$" // VIN must be 17 characters long and exclude I, O, Q
        let vinTest = NSPredicate(format: "SELF MATCHES %@", vinRegex)
        return vinTest.evaluate(with: vin)
    }

    // MARK: - Save Booking to Firebase

    // Function to save the booking details to Firebase
    private func saveBooking() {
        // Access the Firebase Realtime Database
        let db = Database.database().reference()
        
        // Prepare the booking data to save
        let bookingData: [String: Any] = [
            "name": name,
            "address": address,
            "city": city,
            "phoneNumber": phoneNumber,
            "vehicleMake": vehicleMake,
            "vehicleModel": vehicleModel,
            "vehicleYear": vehicleYear,
            "vinNumber": vinNumber,
            "mileage": mileage,
            "complaint": complaint,
            "date": formattedDate(selectedDate) // Store the formatted selected date
        ]
        
        // Save the booking data in Firebase under the "bookings" node
        db.child("bookings").childByAutoId().setValue(bookingData) { error, _ in
            if let error = error {
                // Handle any errors that occur during the save operation
                alertMessage = "There was a problem saving your booking: \(error.localizedDescription)"
                isBookingSuccessful = false
                showingAlert = true
            } else {
                // If successful, show a success message and clear the form
                alertMessage = "Your booking has been successfully submitted. You will receive a confirmation email or text once your appointment has been confirmed."
                isBookingSuccessful = true
                showingAlert = true
                clearForm() // Clear the form after successful submission
            }
        }
    }

    // MARK: - Clear Form
    
    // Function to clear the form fields after successful submission
    private func clearForm() {
        name = ""
        address = ""
        city = ""
        phoneNumber = ""
        vehicleMake = ""
        vehicleModel = ""
        vehicleYear = ""
        vinNumber = ""
        mileage = ""
        complaint = ""
    }
    
    // MARK: - Helper Function
    
    // Function to format the date for display in the form's title
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // Display date in medium format (e.g., Jan 1, 2024)
        return formatter.string(from: date)
    }
}
