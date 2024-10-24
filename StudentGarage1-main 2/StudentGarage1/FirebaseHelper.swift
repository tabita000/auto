//

//  FirebaseHelper.swift

//  StudentGarage1

//

//  Created by student on 9/29/24.

//

 

import Firebase

import SwiftUI

 

// MARK: - FirebaseHelper Struct

// FirebaseHelper struct that handles interactions with Firebase, particularly fetching available dates.

struct FirebaseHelper {

   

    // MARK: - Public Methods

   

    // Static function to load available dates from Firebase.

    // The completion handler returns an array of available dates asynchronously.

    static func loadAvailableDates(completion: @escaping ([Date]) -> Void) {

       

        // MARK: - Date Range Setup

       

        // Define the start and end dates for available bookings.

        let startDate = Calendar.current.date(from: DateComponents(year: 2024, month: 8, day: 23))! // Start on August 23, 2024

        let endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 17))!   // End on May 17, 2025

       

        var dates: [Date] = []           // Array to hold all possible booking dates.

        var currentDate = startDate      // Set the current date to the start date.

       

        // Loop through each day from the start date to the end date.

        while currentDate <= endDate {

            // Check if the current day is a Friday (weekday == 6).

            if Calendar.current.component(.weekday, from: currentDate) == 6 {

                dates.append(currentDate)  // Add Fridays to the list of available dates.

            }

            // Move to the next day.

            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!

        }

       

        // MARK: - Firebase Data Fetching

       

        // Access the Firebase database.

        let db = Database.database().reference()

       

        // Read data from the "bookings" node in the database once.

        db.child("bookings").observeSingleEvent(of: .value) { snapshot in

            var bookedDates: [Date] = []  // Array to hold booked dates from Firebase.

 

            // Loop through each child node in the "bookings" snapshot.

            for child in snapshot.children {

                if let childSnapshot = child as? DataSnapshot,

                   let bookingData = childSnapshot.value as? [String: Any],

                   let dateString = bookingData["date"] as? String,

                   let date = dateString.toDate(withFormat: "yyyy-MM-dd") {  // Convert the date string to a Date object using the 'toDate()' extension.

                    bookedDates.append(date)  // Add the booked date to the array.

                }

            }

           

            // MARK: - Date Filtering

           

            // Filter available dates to only include dates in the future and not already booked.

            let today = Date()

            let availableDates = dates.filter { date in

                return !bookedDates.contains(date) && date > today // Only future dates not in bookedDates.

            }

           

            // Call the completion handler, returning the list of available dates.

            completion(availableDates)

        }

    }

}

 

// MARK: - String toDate Extension

// String extension to convert a date string into a Date object

extension String {

    func toDate(withFormat format: String = "yyyy-MM-dd") -> Date? {

        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = format

        dateFormatter.timeZone = TimeZone.current

        dateFormatter.locale = Locale.current

        return dateFormatter.date(from: self)

    }

}
