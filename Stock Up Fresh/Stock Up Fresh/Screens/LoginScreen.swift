//
//  LoginScreen.swift
//  Stock Up Fresh
//
//  Created by Biraj Dahal on 4/5/25.
//

import SwiftUI

struct LoginScreen: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isShowingPassword: Bool = false
    @State private var rememberMe: Bool = false
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
                        
                        HStack {
                            
                            Spacer()
                            
                            Button("Forgot Password?") {
                                
                            }
                            .font(.subheadline)
                            .foregroundColor(Color.appOlive)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        signIn()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 5)
                            }
                            Text("Sign In")
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
                        Text("Don't have an account?")
                            .foregroundColor(.secondary)
                        
                        Button("Sign Up") {
                            
                        }
                        .foregroundColor(Color.appOlive)
                        .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .padding(.top, 8)
                    
                    VStack(spacing: 16) {
                        Text("Or continue with")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 20) {
                            socialButton(iconName: "applelogo", action: {

                            })
                            .foregroundStyle(Color.black)
                            
                            socialButton(iconName: "g.circle.fill", action: {
                    
                            })
                            .foregroundStyle(Color.black)
                            
                            socialButton(iconName: "envelope.fill", action: {
            
                            })
                            .foregroundStyle(Color.black)
                        }
                    }
                    .padding(.top, 16)
                }
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Sign In"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func socialButton(iconName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(Circle())
        }
    }
    
    private func signIn() {
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
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alertMessage = "Successfully signed in!"
            showAlert = true
            isLoading = false
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}
