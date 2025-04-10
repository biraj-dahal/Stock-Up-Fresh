//
//  SignupScreen.swift
//  Stock Up Fresh
//
//  Created by Biraj Dahal on 4/9/25.
//

import SwiftUI

struct SignupScreen: View {
        @State private var name: String = ""
        @State private var email: String = ""
        @State private var password: String = ""
        @State private var reenter_password: String = ""
        @State private var isShowingPassword: Bool = false
        @State private var isLoading: Bool = false
        @State private var showAlert: Bool = false
        @State private var alertMessage: String = ""
        
        var body: some View {
            NavigationView {
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 1) {
                            Image(.stockUpFreshLogo)
                                .resizable()
                                .frame(width: 200, height: 200)
      
                        }
                        .padding(.top, 50)
                        .padding(.bottom, 0)
                        
                        
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                
                                TextField("Enter Full Name", text: $name)
                                    .disableAutocorrection(true)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                
                                TextField("Enter Email Address", text: $email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                            }
                            
                            
                            VStack(alignment: .leading, spacing: 8) {

                                
                                ZStack(alignment: .trailing) {
                                    if isShowingPassword {
                                        TextField("Enter Password", text: $password)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                            .padding()
                                            .background(Color(.systemGray6))
                                            .cornerRadius(10)
                                    } else {
                                        SecureField("Enter Password", text: $password)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                            .padding()
                                            .background(Color(.systemGray6))
                                            .cornerRadius(10)
                                    }
                                    
                                    Button(action: {
                                        isShowingPassword.toggle()
                                    }) {
                                        Image(systemName: isShowingPassword ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.trailing, 16)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {

                                
                                ZStack(alignment: .trailing) {
                                    if isShowingPassword {
                                        TextField("Re-enter Password", text: $reenter_password)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                            .padding()
                                            .background(Color(.systemGray6))
                                            .cornerRadius(10)
                                    } else {
                                        SecureField("Re-enter Password", text: $reenter_password)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                            .padding()
                                            .background(Color(.systemGray6))
                                            .cornerRadius(10)
                                    }
                                    
                                    Button(action: {
                                        isShowingPassword.toggle()
                                    }) {
                                        Image(systemName: isShowingPassword ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.trailing, 16)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            signUp()
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .padding(.trailing, 5)
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
                    
                    }
                    .padding(.bottom, 40)
                }
                .navigationBarHidden(true)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Sign Up"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
        
        
        private func signUp() {
            guard !email.isEmpty else {
                alertMessage = "Please enter your email"
                showAlert = true
                return
            }
            
            guard !password.isEmpty else {
                alertMessage = "Please enter your password"
                showAlert = true
                return
            }
            guard !reenter_password.isEmpty else {
                alertMessage = "Please re-enter your password"
                showAlert = true
                return
            }
            guard !name.isEmpty else {
                alertMessage = "Please enter your name"
                showAlert = true
                return
            }
            guard reenter_password.elementsEqual(password) else {
                alertMessage = "Passwords do not match"
                showAlert = true
                return
            }
            
            isLoading = true
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                alertMessage = "Successfully signed Up!"
                showAlert = true
                isLoading = false
            }
        }
    }

#Preview {
    SignupScreen()
}
