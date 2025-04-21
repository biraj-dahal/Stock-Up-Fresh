//
//  SignupScreen.swift
//  Stock Up Fresh
//
//  Created by Biraj Dahal on 4/9/25.
//

import SwiftUI
import FirebaseAuth

struct SignupScreen: View {
@Binding var path: [AuthDestination]
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isShowingPassword: Bool = false
    @State private var isShowingConfirmPassword: Bool = false
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(.stockUpFreshLogo)
                    .resizable()
                    .frame(width: 150, height: 150)
                    .padding(.top, 30)
                
                Text("Create Account")
                    .font(.title2)
                    .fontWeight(.bold)

                VStack(spacing: 16) {
                    TextField("Full Name", text: $fullName)
                        .autocapitalization(.words)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    TextField("Email Address", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    ZStack(alignment: .trailing) {
                        if isShowingPassword {
                            TextField("Password", text: $password)
                        } else {
                            SecureField("Password", text: $password)
                        }

                        Button {
                            isShowingPassword.toggle()
                        } label: {
                            Image(systemName: isShowingPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.secondary)
                        }
                        .padding(.trailing, 16)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    ZStack(alignment: .trailing) {
                        if isShowingConfirmPassword {
                            TextField("Confirm Password", text: $confirmPassword)
                        } else {
                            SecureField("Confirm Password", text: $confirmPassword)
                        }

                        Button {
                            isShowingConfirmPassword.toggle()
                        } label: {
                            Image(systemName: isShowingConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.secondary)
                        }
                        .padding(.trailing, 16)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                Button(action: {
                    signUp()
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(width: 20, height: 20)
                        } else {
                            Color.clear.frame(width: 20, height: 20)
                        }

                        Text("Sign Up")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appBeige)
                    .foregroundColor(.appOlive)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(isLoading)

                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.secondary)

                    Button("Sign In") {
                        path.removeLast()
                    }
                    .foregroundColor(Color.appOlive)
                    .fontWeight(.semibold)
                }
                .font(.subheadline)
                .padding(.top, 8)
            }
            .padding(.bottom, 40)
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Sign Up"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func signUp() {
        // Input validation
        guard !fullName.isEmpty else {
            alertMessage = "Please enter your full name"
            showAlert = true
            return
        }
        
        guard !email.isEmpty else {
            alertMessage = "Please enter your email"
            showAlert = true
            return
        }

        guard !password.isEmpty else {
            alertMessage = "Please enter a password"
            showAlert = true
            return
        }
        
        guard password.count >= 6 else {
            alertMessage = "Password must be at least 6 characters"
            showAlert = true
            return
        }
        
        guard password == confirmPassword else {
            alertMessage = "Passwords do not match"
            showAlert = true
            return
        }

        isLoading = true

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                isLoading = false
                alertMessage = error.localizedDescription
                showAlert = true
                return
            }
            

            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = fullName
            changeRequest?.commitChanges { error in
                isLoading = false
                
                if let error = error {
                    alertMessage = error.localizedDescription
                    showAlert = true
                    return
                }
                

                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                
                path.removeAll()
                path.append(.authFlow)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignupScreen(path: .constant([]))
    }
}
