//
//  CustomButton.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 12/02/2026.
//

import SwiftUI
import Combine

struct CustomButton: View {
    var placeholder: String
    var action: () -> Void // 1. Add this line to accept an action
    
    var body: some View {
        Button {
            action() // 2. Execute the action when tapped!
        } label: {
            Text(placeholder)
                .foregroundStyle(.white)
                .padding(.all)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.gradientStart, Color.gradientend]), startPoint: .bottom, endPoint: .top)
                )
                .cornerRadius(8)
        }
    }
}
