//
//    SettingsView.swift
//  Stock Up Fresh
//
//  Created by Noah Seid on 4/7/25.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @State private var lowStockAlertsEnabled = true
    @State private var locationRemindersEnabled = true
    @State private var calendarIntegrationEnabled = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBeige
                    .ignoresSafeArea()

                Form {
                    Section(header: Text("Notifications").foregroundColor(.appOlive)) {
                        Toggle(isOn: $lowStockAlertsEnabled) {
                            Label("Low-stock Alerts", systemImage: "bell.badge")
                                .foregroundColor(.appOlive)
                        }

                        Toggle(isOn: $locationRemindersEnabled) {
                            Label("Location-based Reminders", systemImage: "location.fill")
                                .foregroundColor(.appOlive)
                        }
                    }

                    Section(header: Text("Integrations").foregroundColor(.appOlive)) {
                        Toggle(isOn: $calendarIntegrationEnabled) {
                            Label("Apple Calendar", systemImage: "calendar")
                                .foregroundColor(.appOlive)
                        }
                    }

                    Section(header: Text("Account").foregroundColor(.appOlive)) {
                        NavigationLink(destination: ManageAccountView()) {
                            Label("Manage Account", systemImage: "person.crop.circle")
                                .foregroundColor(.appOlive)
                        }
                    }
                }
                .scrollContentBackground(.hidden) // Makes the Form background transparent so appBeige shows
            }
            .navigationTitle("Settings")
        }
    }
}

struct ManageAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        Form {
            Section(header: Text("Account Actions")) {
                Button(role: .destructive) {
                    authManager.signOut()
                } label: {
                    HStack {
                        Image(systemName: "power")
                        Text("Sign Out")
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .background(Color.appBeige)
        .navigationTitle("Manage Account")
        
    }
}

#Preview {
    SettingsView()
}
