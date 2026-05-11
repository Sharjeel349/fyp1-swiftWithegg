//
//  CustomTextField.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 12/02/2026.
//

//import SwiftUI
//
//struct CustomTextField: View {
//    @Binding var controller:String
//    var Text:String
//    @State var issecurre:Bool=false
//    @Binding var isObsecurre:Bool
//    var  Icon:String
//    var body: some View {
//        HStack{
//            Image(systemName: Icon)
//                .foregroundStyle(.gray)
//            if(issecurre){
//                SecureField(Text, text: $controller)
//                Button(action: {
//                                issecurre.toggle()
//                            }) {
//                                Image(systemName: self.issecurre ? "eye.slash" : "eye")
//                                    .accentColor(.gray)
//                            }
//            }
//            else{
//                TextField(Text, text: $controller)
//            }
//        }.padding()
//            .background(.white).cornerRadius(12)
//            .shadow(radius: 2,x: 0,y: 1)
//    }
//}
//


import SwiftUI
import Combine

struct CustomTextField: View {
    
    @Binding var text: String
    var placeholder: String
    var icon: String
    var isPasswordField: Bool = false
    
    @State private var isSecure: Bool = true
    
    var body: some View {
        HStack {
            
            Image(systemName: icon)
                .foregroundStyle(.gray)
            
            if isPasswordField {
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
                
                Button(action: {
                    isSecure.toggle()
                }) {
                    Image(systemName: isSecure ? "eye.slash" : "eye")
                        .foregroundStyle(.black)
                }
                
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
    }
}
