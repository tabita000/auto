import SwiftUI

// MARK: - String Extension for Date Conversion
extension String {
    func toDate(format: String = "yyyy-MM-dd") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.date(from: self)
    }
}

// MARK: - CustomCalendarView
struct CustomCalendarView: View {
    @State private var availableDates: [Date] = []
    @State private var selectedDate: Date?
    @State private var showingBookingForm = false

    @State private var currentMonth: Date = Date()
    @State private var showOnlyFutureDates = true
    @Environment(\.presentationMode) var presentationMode

    var showBackButton: Bool = true // Parameter to control the back button visibility

    var body: some View {
        ZStack {
            Color(red: 253/255, green: 186/255, blue: 49/255)
                .edgesIgnoringSafeArea(.all)

            VStack {
                if showBackButton {
                    // Top Navigation with Back Button and Bell Icon
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                Text("Back")
                            }
                            .font(.headline)
                            .foregroundColor(.black)
                        }
                        .padding(.leading, 20)

                        Spacer()

                        Button(action: {
                            // Bell icon action
                        }) {
                            Image(systemName: "bell")
                                .font(.system(size: 25))
                                .foregroundColor(.black)
                        }
                        .padding(.trailing, 20)
                    }
                    .padding(.top, 40)
                }

                Spacer()

                // Toggle for showing future dates only
                Toggle("Show Only Future Dates", isOn: $showOnlyFutureDates)
                    .padding()

                Text("Select a Date")
                    .font(.largeTitle)
                    .padding()

                // Calendar Header and Grid
                VStack {
                    CalendarHeader(currentMonth: $currentMonth)

                    CalendarGridView(currentMonth: currentMonth, availableDates: availableDates, selectedDate: $selectedDate) {
                        showingBookingForm = true
                    }
                    .padding([.leading, .trailing], 20)
                }
                .onAppear {
                    loadAvailableDates()
                }
                .sheet(isPresented: $showingBookingForm) {
                    if let selectedDate = selectedDate {
                        BookingFormView(selectedDate: selectedDate)
                    }
                }

                Spacer()

                // Bottom Toolbar with Image
                HStack {
                    Spacer()
                    Image("MCC-copy")
                        .resizable()
                        .frame(width: 200, height: 60)
                        .padding()
                    Spacer()
                }
                .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Load Available Dates
    private func loadAvailableDates() {
        FirebaseHelper.loadAvailableDates { dates in
            self.availableDates = dates
        }
    }

    // MARK: - Calendar Header
    struct CalendarHeader: View {
        @Binding var currentMonth: Date

        var body: some View {
            HStack {
                Button(action: { moveMonth(-1) }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(currentMonthTitle)
                    .font(.headline)
                Spacer()
                Button(action: { moveMonth(1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
        }

        var currentMonthTitle: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: currentMonth)
        }

        func moveMonth(_ offset: Int) {
            currentMonth = Calendar.current.date(byAdding: .month, value: offset, to: currentMonth)!
        }
    }

    // MARK: - Calendar Grid View
    struct CalendarGridView: View {
        var currentMonth: Date
        var availableDates: [Date]
        @Binding var selectedDate: Date?

        var onDateSelected: () -> Void

        private let columns = Array(repeating: GridItem(.flexible()), count: 7)

        var body: some View {
            VStack {
                HStack {
                    ForEach(getDayNames(), id: \.self) { dayName in
                        Text(dayName)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 5)

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(getDaysInMonth(), id: \.self) { date in
                        if let date = date {
                            Button(action: {
                                selectedDate = date
                                onDateSelected()
                            }) {
                                Text(formatDate(date))
                                    .frame(maxWidth: .infinity, maxHeight: 40)
                                    .background(getDateColor(date))
                                    .foregroundColor(isAvailable(date) ? .white : .black)
                                    .cornerRadius(8)
                            }
                            .disabled(!isAvailable(date))
                        } else {
                            Text("")
                                .frame(maxWidth: .infinity, maxHeight: 40)
                        }
                    }
                }
            }
        }

        private func getDayNames() -> [String] {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            return formatter.shortWeekdaySymbols
        }

        private func getDaysInMonth() -> [Date?] {
            let calendar = Calendar.current
            let range = calendar.range(of: .day, in: .month, for: currentMonth)!
            var dates: [Date?] = []
            let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
            let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
            dates.append(contentsOf: Array(repeating: nil, count: firstWeekday - 1))
            for day in range {
                let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)!
                dates.append(date)
            }
            return dates
        }

        private func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "d"
            return formatter.string(from: date)
        }

        private func isAvailable(_ date: Date) -> Bool {
            return availableDates.contains(date)
        }

        private func getDateColor(_ date: Date) -> Color {
            if isAvailable(date) {
                return .green
            } else if Calendar.current.isDateInToday(date) {
                return .orange
            } else {
                return .gray.opacity(0.5)
            }
        }
    }
}

struct CustomCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CustomCalendarView()
    }
}
