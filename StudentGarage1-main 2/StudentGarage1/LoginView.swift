import SwiftUI
import AVKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore

// VideoPlayerViewModel to manage the AVPlayer instance
class VideoPlayerViewModel: ObservableObject {
    @Published var videoPlayer: AVPlayer?
    
    init() {
        if let videoURL = Bundle.main.url(forResource: "carVideo", withExtension: "mp4") {
            videoPlayer = AVPlayer(url: videoURL)
            videoPlayer?.actionAtItemEnd = .none
            
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: videoPlayer?.currentItem,
                queue: .main
            ) { [weak self] _ in
                self?.videoPlayer?.seek(to: .zero)
                self?.videoPlayer?.play()
            }
        } else {
            print("Error: Video file 'carVideo.mp4' not found in the bundle.")
        }
    }
}

struct ContentView: View {
    // State variables for login and navigation
    @State private var email = ""
    @State private var password = ""
    @State private var adminPassword = ""
    @State private var isAdmin = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoggedIn = false
    @State private var bounceOffset: CGFloat = -UIScreen.main.bounds.width
    
    @StateObject private var viewModel = VideoPlayerViewModel()
    let adminAccessPassword = "YourAdminPassword123"

    var body: some View {
        if isLoggedIn {
            // Show MainTabView once the user is logged in
            MainTabView()
        } else {
            // Show the login form initially
            loginView
        }
    }
    
    // Login form view
    private var loginView: some View {
        ZStack {
            Color(red: 253/255, green: 186/255, blue: 49/255)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack(spacing: 10) {
                    Image("MCC_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                    
                    Text("STUDENT GARAGE")
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(Color(red: 0.29, green: 0.19, blue: 0.56))
                        .shadow(color: .gray, radius: 2, x: 1, y: 1)
                }
                .offset(x: bounceOffset)
                .onAppear {
                    withAnimation(.easeOut(duration: 1.0)) {
                        bounceOffset = 20
                    }
                    withAnimation(Animation.easeOut(duration: 0.5).delay(1.0)) {
                        bounceOffset = -20
                    }
                    withAnimation(Animation.easeOut(duration: 0.3).delay(1.5)) {
                        bounceOffset = 0
                    }
                }
                .padding(.top, 50)
                
                if let videoPlayer = viewModel.videoPlayer {
                    VideoPlayer(player: videoPlayer)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .onAppear {
                            videoPlayer.play()
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                } else {
                    Text("Video unavailable")
                        .foregroundColor(.red)
                        .padding()
                }
                
                loginForm
                
                Spacer()
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // Login form subview
    private var loginForm: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 20)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 20)
            
            Toggle("Admin", isOn: $isAdmin)
                .padding(.horizontal, 20)
            
            if isAdmin {
                SecureField("Admin Password", text: $adminPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)
            }
            
            HStack(spacing: 30) {
                Button(action: login) {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(red: 74/255, green: 49/255, blue: 144/255))
                        .cornerRadius(10)
                }
                
                Button(action: createAccount) {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(red: 74/255, green: 49/255, blue: 144/255))
                        .cornerRadius(10)
                }
            }
            .padding(.top, 20)
        }
    }
    
    // Login function
    private func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showingAlert = true
                return
            }
            
            guard let user = result?.user else { return }
            
            if isAdmin {
                let db = Firestore.firestore()
                db.collection("admins").document(user.uid).getDocument { document, error in
                    if let document = document, document.exists {
                        isLoggedIn = true
                    } else {
                        alertMessage = "Admin access not found!"
                        showingAlert = true
                    }
                }
            } else {
                let dbRef = Database.database().reference()
                dbRef.child("users").child(user.uid).observeSingleEvent(of: .value) { snapshot in
                    if snapshot.exists() {
                        isLoggedIn = true
                    } else {
                        dbRef.child("users").child(user.uid).setValue(["email": email]) { error, _ in
                            if let error = error {
                                alertMessage = error.localizedDescription
                                showingAlert = true
                            } else {
                                isLoggedIn = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Create account function
    private func createAccount() {
        if isAdmin {
            guard adminPassword == adminAccessPassword else {
                alertMessage = "Incorrect admin password!"
                showingAlert = true
                return
            }
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showingAlert = true
            } else if let user = result?.user {
                if isAdmin {
                    let db = Firestore.firestore()
                    db.collection("admins").document(user.uid).setData(["email": email, "isAdmin": true]) { error in
                        if let error = error {
                            alertMessage = error.localizedDescription
                            showingAlert = true
                        } else {
                            alertMessage = "Admin account created!"
                            showingAlert = true
                            isLoggedIn = true
                        }
                    }
                } else {
                    let dbRef = Database.database().reference()
                    dbRef.child("users").child(user.uid).setValue(["email": email]) { error, _ in
                        if let error = error {
                            alertMessage = error.localizedDescription
                            showingAlert = true
                        } else {
                            alertMessage = "Account created! Please verify your email."
                            showingAlert = true
                            isLoggedIn = true
                        }
                    }
                }
                
                user.sendEmailVerification { error in
                    if let error = error {
                        alertMessage = error.localizedDescription
                        showingAlert = true
                    } else {
                        alertMessage = "Verification email sent! Please check your inbox."
                        showingAlert = true
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
