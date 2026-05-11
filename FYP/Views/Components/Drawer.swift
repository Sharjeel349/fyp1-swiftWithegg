import SwiftUI

struct DrawerBtn: View {
    var placeholder: String
    @Binding var selectedRole: String 
    
    var body: some View {
        Button {
            selectedRole = placeholder 
        } label: {
            Text(placeholder)
                .foregroundStyle(selectedRole == placeholder ? .white:.black)
                .padding(.all, 10)
                .frame(maxWidth: .infinity)
                .background(
                    selectedRole == placeholder ?
                    LinearGradient(
                        gradient: Gradient(colors: [Color.gradientStart, Color.gradientend]),
                        startPoint: .bottom, endPoint: .top) :
                    LinearGradient(
                        gradient: Gradient(colors: [Color.main, Color.main]),
                        startPoint: .bottom, endPoint: .top)
                )
                .cornerRadius(8)
        }
    }
}
