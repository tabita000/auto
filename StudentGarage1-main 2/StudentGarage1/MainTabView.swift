import SwiftUI

struct MainTabView: View {
    let mccAutoDpt: String = "(815) 479-7521" // MCC automotive department phone number

    var body: some View {
        TabView {
            // Home Tab (CustomCalendarView)
            CustomCalendarView(showBackButton: false)
                .tabItem {
                    VStack {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                }

            // Phone Tab - Triggers Call to MCC
            Button(action: {
                // Action to dial the MCC automotive department
                if let url = URL(string: "tel:\(mccAutoDpt)") {
                    UIApplication.shared.open(url)
                }
            }) {
                VStack {
                    Image(systemName: "phone.fill")
                    Text("Phone")
                }
            }
            .tabItem {
                VStack {
                    Image(systemName: "phone.fill")
                    Text("Phone")
                }
            }

            // Inbox Tab (BookingFormView)
            BookingFormView(selectedDate: Date())
                .tabItem {
                    VStack {
                        Image(systemName: "envelope.fill")
                        Text("Inbox")
                    }
                }

            // Calendar Tab (CustomCalendarView)
            CustomCalendarView(showBackButton: false)
                .tabItem {
                    VStack {
                        Image(systemName: "calendar")
                        Text("Calendar")
                    }
                }
        }
        .accentColor(Color(red: 74/255, green: 49/255, blue: 144/255)) // Active tab color
        .background(.black)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
