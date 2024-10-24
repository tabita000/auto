//
//  ContentView.swift
//  autoApp
//
//  Created by Tabita Sadiq on 9/26/24.
//

import SwiftUI

struct ContentView: View {
    
    
    @State private var isAdmin: Bool = false //declaring the @State variable isAdmin
    
    var body: some View {
        ZStack {
            Color(red: 253/255, green: 186/255, blue: 49/255)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Image("MCC_icon") //MCC_icon.png
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.top, 50)
                
                // text for app name Student Garage
                Text("STUDENT \nGARAGE")
                    .font(Font.custom("Jacques Francois", size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.29, green: 0.19, blue: 0.56))
                    .frame(width: 324, height: 82, alignment: .top)
                    .padding(.top, 10)
                
                
                
                //Spacer() // adding this spacer moves the entire block that is email address password, and the four login/signup options towards the bottom.
                    .frame(height: 200) // spacer() adds a default space but .frame() will allow me to add spaces according to whatever I need---meaning for additional space
                
                
                // Admin Toggle and Email/Password Fields
                VStack(spacing: 10) {
                    
                   
                    
                    // Admin Toggle
                    HStack {
                        Spacer() // Push the HStack content to the right
                        
                        
                        Text("Admin")
                            .foregroundColor(.black)
                            .font(.headline)
                        
                        Toggle(isOn: $isAdmin) {
                            EmptyView() // This keeps the text from being attached to the toggle
                        }
                        .labelsHidden() // Hide the default toggle label
                        .toggleStyle(SwitchToggleStyle(tint: .black))
                    }
                    .padding(.trailing, 20) 
                    
                    
                    // Email and Password Fields
                    VStack(spacing: 20) {
                        TextField("Email Address", text: .constant(""))
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                        
                        SecureField("Password", text: .constant(""))
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                    }
                    
                    //Spacer()
                    
                    // Sign In Button
                    Button(action: {
                        // Action for sign in
                    }) {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 220, height: 50)
                            .background(Color(red: 74/255, green: 49/255, blue: 144/255))
                            .cornerRadius(20)
                    }
                    .padding(.bottom, 10)
                    
                    // Sign Up Button
                    Button(action: {
                        // Action for sign up
                    }) {
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 220, height: 50)
                            .background(Color(red: 74/255, green: 49/255, blue: 144/255))
                            .cornerRadius(20)
                    }
                    .padding(.bottom, 20)
                    
                    // Sign-in options (side-by-side buttons for Apple and Google)
                    HStack(spacing: 30) {
                        
                        // Apple Login Button
                        Button(action: {
                            // Action for logging in with Apple
                        }) {
                            Image(systemName: "applelogo")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black) // Apple branding color
                                .cornerRadius(10)
                        }
                        
                        // Google Login Button
                        Button(action: {
                            // Action for logging in with Google
                        }) {
                            Image("google") //asset IMG
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.bottom, 50)
                    
                    Spacer()
                }
                
                // Toolbar--home and calender
                VStack {
                    Spacer()
                    HStack {
                        // Home Button
                        Button(action: {
                            // Action for home button
                        }) {
                            HStack {
                                Image(systemName: "house.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                
                            }
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                        }
                        
                        .padding(.leading, 20)
                        
                        Spacer()
                        
                        // Calendar Button
                        Button(action: {
                            // Action for calendar button
                        }) {
                            HStack {
                                Image(systemName: "calendar")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding()
                        }
                        
                        .padding(.trailing, 20)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    
}
