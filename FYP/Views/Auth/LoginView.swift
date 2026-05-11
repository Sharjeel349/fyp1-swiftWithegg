//
//  LoginView.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 11/02/2026.
//

import SwiftUI
import Combine

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State var mail:String = "";
    @State var Pass:String = "";
    @State var selectedRole:String = "Student";
    var body: some View {
            // 2. Setup navigation to your home screen
            NavigationStack {
                VStack {
                    topCard
                    formCard
                    Spacer()
                }
                .padding(.horizontal)
                // Navigate to Home when login is successful
                .navigationDestination(isPresented: $viewModel.navigateToHome) {
                    ChatSessionsScreen() // Replace with your actual home view
                        .navigationBarBackButtonHidden()
                }
            }
        }
    var topCard:some View {
        ZStack{
            Image("Selection")
                .background(
                    .main
                ).cornerRadius(12)
                .shadow(color: Color.black.opacity(0.5),radius: 6,x: 0,y: 5)
                Image(systemName: "book")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gradientStart,Color.gradientend]), startPoint: .bottom, endPoint: .top)
                    ).cornerRadius(12)
            VStack {
                Spacer()
                Text("University AI Advisor")
                    .font(.title)
                    .bold()
                    .padding(.bottom,20)
            }

        }
        .ignoresSafeArea()
        .frame(height: 220)
    }
    
    
    var formCard: some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack (spacing: 16) {
                    DrawerBtn(placeholder: "Student", selectedRole: $viewModel.selectedRole)
                    DrawerBtn(placeholder: "Teacher", selectedRole: $viewModel.selectedRole)
                }
                .padding(.all, 14)
                .background(.white)
                .cornerRadius(12)
                
                Text("Email Address").padding(.top, 30)
                CustomTextField(text: $viewModel.email, placeholder: "abc@gmail.com", icon: "envelope.fill")
                    .padding(.top, 8)
                    // Handy modifiers for emails:
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                Text("Password").padding(.top, 20)
                CustomTextField(text: $viewModel.password, placeholder: "Password", icon: "lock.fill", isPasswordField: true)
                    .padding(.top, 8)
                
                // Show errors if they exist
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, 10)
                }
                
                // Assuming CustomButton accepts an action. If it doesn't, wrap it in a standard Button.
                Button(action: {
                    Task {
                        await viewModel.performLogin()
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue) // Adjust to your theme
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.top, 40)
                    } else {
                        // Place your CustomButton UI here if it doesn't take an action parameter natively
                        CustomButton(placeholder: "Sign In", action: {
                            Task {
                                await viewModel.performLogin()
                            }
                        })
                        .padding(.top, 40)
                    }
                }
                .disabled(viewModel.isLoading)
            }
            .padding()
            .padding(.vertical, 30)
            .background(Color.main)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.5), radius: 6, x: 0, y: 5)
        }
    }
