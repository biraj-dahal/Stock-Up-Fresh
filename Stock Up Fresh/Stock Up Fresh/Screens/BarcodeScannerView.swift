//
//  BarcodeScannerView.swift
//  Stock Up Fresh
//
//  Created by Noah Seid on 4/7/25.

import SwiftUI
import UIKit

struct BarcodeScannerView: View {
    @State private var showCamera = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        // A nearly invisible view that immediately triggers the camera sheet
        Color.clear
            .onAppear {
                showCamera = true
            }
            .sheet(isPresented: $showCamera, onDismiss: {
                // Optional: do something when dismissed
                print("🔙 Camera dismissed")
            }) {
                CameraWrapperView()
            }
    }
}
#Preview {
    BarcodeScannerView()
}
