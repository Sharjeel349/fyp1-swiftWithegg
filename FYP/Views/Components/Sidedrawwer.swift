//
//  Sidedrawwer.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 13/02/2026.
//
//import SwiftUI
//struct SideMenu: View {
//    // 1. Initialize the ViewModel
//    @StateObject private var viewModel = SideMenuViewModel()
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            
//            HStack {
//                Image(systemName: "clock.arrow.circlepath")
//                    .foregroundColor(.white)
//                Text("Chat History")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//            }
//            .padding(.top, 50)
//            .padding(.horizontal)
//            
//            Divider()
//                .background(Color.white.opacity(0.5))
//                .padding(.horizontal)
//            
//            ScrollView {
//                VStack(alignment: .leading, spacing: 20) {
//                    if viewModel.isLoading {
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                            .frame(maxWidth: .infinity, alignment: .center)
//                    } else if let errorMessage = viewModel.errorMessage {
//                        Text(errorMessage)
//                            .foregroundColor(.red)
//                            .font(.caption)
//                    } else if viewModel.chatSessions.isEmpty {
//                        Text("No chat history yet.")
//                            .foregroundColor(.gray)
//                            .font(.caption)
//                    } else {
//                        // 3. Loop through the actual API data!
//                        ForEach(viewModel.chatSessions) { session in
//                            HistoryItem(
//                                title: session.title,
//                                date: viewModel.formatFriendlyDate(from: session.startTime)
//                            )
//                        }
//                    }
//                }
//                .padding()
//            }
//            
//            Spacer()
//            
//            HStack {
//                Image(systemName: "plus")
//                    .foregroundColor(.gray)
//        
//                Text("New Chat")
//                    .bold()
//                    .foregroundColor(.gray)
//            }
//            .padding()
//        }
//        .background(Color.gradientStart) // Make sure you have this Color extension!
//        .edgesIgnoringSafeArea(.vertical)
//        // 4. Trigger the fetch exactly when the menu slides onto the screen
//        .task {
//            await viewModel.loadHistory()
//        }
//    }
//}
//
//struct HistoryItem: View {
//    let title: String
//    let date: String
//    
//    var body: some View {
//            HStack {
//                Image(systemName: "message")
//                    .foregroundColor(.gray)
//                VStack(alignment: .leading) {
//                    Text(title)
//                        .foregroundColor(.white)
//                        .font(.body)
//                    Text(date)
//                        .foregroundColor(.gray)
//                        .font(.caption)
//                }
//            }
//    }
//}


import SwiftUI

struct SideMenu: View {
    @StateObject private var viewModel = SideMenuViewModel()
    
    // This closure passes the selected session ID back to the main view
    var onSessionSelect: ((Int?) -> Void)
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.white)
                Text("Chat History")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.top, 50)
            .padding(.horizontal)
            
            Divider()
                .background(Color.white.opacity(0.5))
                .padding(.horizontal)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    } else if viewModel.chatSessions.isEmpty {
                        Text("No chat history yet.")
                            .foregroundColor(.gray)
                            .font(.caption)
                    } else {
                        ForEach(viewModel.chatSessions) { session in
                            // Make the history item tappable
                            Button {
                                onSessionSelect(session.id)
                            } label: {
                                HistoryItem(
                                    title: session.title,
                                    date: viewModel.formatFriendlyDate(from: session.startTime)
                                )
                            }
                        }
                    }
                }
                .padding()
            }
            
            Spacer()
            
            // New Chat Button
            Button {
                onSessionSelect(nil) // nil means start a brand new chat
            } label: {
                HStack {
                    Image(systemName: "plus")
                        .foregroundColor(.gray)
                    Text("New Chat")
                        .bold()
                        .foregroundColor(.gray)
                }
                .padding()
            }
        }
        .background(Color.gradientStart)
        .edgesIgnoringSafeArea(.vertical)
        .task {
            await viewModel.loadHistory()
        }
    }
}

struct HistoryItem: View {
    let title: String
    let date: String
    
    var body: some View {
        HStack {
            Image(systemName: "message")
                .foregroundColor(.gray)
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                Text(date)
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
    }
}



