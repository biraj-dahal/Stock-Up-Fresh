//
//  AuthFlow.swift
//  Stock Up Fresh
//
//  Created by Biraj Dahal on 4/11/25.
//

import SwiftUI

struct AuthFlow: View {
    @State private var path: [AuthDestination] = []

    var body: some View {
        NavigationStack(path: $path) {
            LoginScreen(path: $path)
                .navigationDestination(for: AuthDestination.self) { destination in
                    switch destination {
                    case .signup:
                        SignupScreen(path: $path)
                    case .groceryList:
                        GroceryListView()
                            .navigationBarBackButtonHidden(true)
                    case .authFlow:
                        HomeTabView()
                    case  .none:
                        EmptyView()
                    }
                }
        }
    }
}

#Preview {
    AuthFlow()
}
