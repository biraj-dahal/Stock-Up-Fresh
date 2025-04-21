
//
//  LoginScreen.swift
//  Stock Up Fresh
//
//  Created by Biraj Dahal on 4/9/25.
//

import SwiftUI
import FirebaseAuth

struct LoginScreen: View {
    @Binding var path: [AuthDestination]
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isShowingPassword: Bool = false
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(.stockUpFreshLogo)
                    .resizable()
                    .frame(width: 200, height: 200)
                    .padding(.top, 50)
                

                VStack(spacing: 16) {
                    TextField("Enter Email Address", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    ZStack(alignment: .trailing) {
                        if isShowingPassword {
                            TextField("Enter Password", text: $password)
                        } else {
                            SecureField("Enter Password", text: $password)
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

                }
                .padding(.horizontal)

                Button(action: {
                    signIn()
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(width: 20, height: 20)
                        } else {
                            Color.clear.frame(width: 20, height: 20)
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
                        path.append(.signup)
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
                        socialButton(iconName: "applelogo") {
                            
                        }
                        .foregroundStyle(.black)
                        socialButton(iconName: "g.circle.fill") {
                            
                        }
                        .foregroundStyle(.black)
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

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            isLoading = false
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
            } else {
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                path.append(.authFlow)
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoginScreen(path: .constant([]))
    }
}
