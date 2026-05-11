//
//  ProfileView.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 01/04/2026.
//


import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    // Use a very light gray/blue background matching your screenshot
    let backgroundColor = Color.main
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView("Loading Profile...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundColor(.red)
            } else if let profile = viewModel.profile {
                // If data is loaded, show the profile content
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // 1. Top Section: User Info
                        VStack(spacing: 8) {
                            // Placeholder Image
                            Circle()
                                .fill(Color.white)
                                .frame(width: 90, height: 90)
                                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                                .overlay(
                                    Image(systemName: "photo.fill")
                                        .foregroundColor(Color.gray.opacity(0.5))
                                        .font(.system(size: 30))
                                )
                                .padding(.top, 20)
                                .padding(.bottom, 10)
                            
                            Text(profile.name)
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text("Registration No: \(profile.registrationNo)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text("Semester: \(profile.semester) | Section: \(profile.sectionCode)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // 2. Middle Section: Academic Report Card
                        NavigationLink(destination: AcademicReportsView()){
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "graduationcap.fill")
                                        .font(.title2)
                                    Text("Academic Report")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    // Format CGPA to 2 decimal places
                                    Text("CGPA: \(String(format: "%.2f", profile.cgpa))")
                                        .font(.largeTitle)
                                        .fontWeight(.heavy)
                                        .foregroundColor(.white)
                                    
                                    Text("Current Academic Standing")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                            }
                            .padding(24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 180)
                            // Use your custom gradient colors here if you have them in assets!
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(red: 0.14, green: 0.36, blue: 0.58), Color(red: 0.04, green: 0.11, blue: 0.18)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                            .padding(.horizontal)
                        }
                        
                        // 3. Bottom Section: Advisor Info
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Advisor")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 16) {
                                // Small Avatar Placeholder
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 45, height: 45)
                                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(Color.gray.opacity(0.5))
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(profile.advisorName)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                    
                                    Text(profile.advisorDesignation)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
            }
        }
        // Native iOS navigation bar styling
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        // Fetch data when the view appears
        .task {
            await viewModel.loadProfile()
        }
    }
}

// Preview to see it in the Canvas quickly
#Preview {
    NavigationView {
        ProfileView()
    }
}
