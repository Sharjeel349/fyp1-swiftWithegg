//
//  ChatSessionScreen.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 12/02/2026.
//

import SwiftUI

//struct ChatSessionScreen: View {
//    @State private var activeSessionId: Int? = nil
//    @State private var showMenu = false
//    let messages: [Message] = [
//        Message(text: "Hello! I'm your University AI Advisor. How can I assist you today?", time: "10:00 AM", isCurrentUser: false, textColor: .black),
//        Message(text: "Hi! I need help with course registration for next semester.", time: "10:01 AM", isCurrentUser: true, textColor: .red),
//        Message(text: "Certainly! To help you best, could you tell me which program you are enrolled in?", time: "10:02 AM", isCurrentUser: false, textColor: .black),
//        Message(text: "I am a Computer Science student, specializing in AI.", time: "10:03 AM", isCurrentUser: true, textColor: .green),
//        Message(text: "I am a Computer Science student, specializing in AI.", time: "10:03 AM", isCurrentUser: false, textColor: .blue),
//        Message(text: "mmein boht pershan ho help chahiya mughe tumhari", time: "10:03 AM", isCurrentUser: true, textColor: .yellow)
//    ]
//    var body: some View {
//        GeometryReader { geometry in
//            let width = geometry.size.width
//            let menuWidth = width * 0.75
//            ZStack(alignment: .bottom) {
//                Color.main.ignoresSafeArea()
//                
//                VStack(spacing: 0) {
//                    appbar
//                    ScrollView {
//                        VStack(spacing: 20) {
//                            ForEach(messages) { message in
//                                MessageBubble(message: message, bubbleWidth: geometry.size.width * 0.75)
//                            }
//                        }
//                        .padding()
//                        .padding(.bottom, 100)
//                    }
//                    VoiceInputBar()
//                }
//                
//                
//            }
//            if showMenu {
//                Color.black.opacity(0.3)
//                    .ignoresSafeArea()
//                    .onTapGesture {
//                        withAnimation(.spring()) {
//                            showMenu = false
//                        }
//                    }
//                    .zIndex(1)
//            }
//            
//            if showMenu {
//                SideMenu()
//                    .frame(width: menuWidth)
//                    .transition(.move(edge: .leading))
//                    .zIndex(2)
//            }
//        }
//        .animation(.spring(), value: showMenu)
//    }
//    
//    
//    var appbar : some View{
//        HStack {
//            Button(action: {
//                withAnimation {
//                    showMenu.toggle()
//                }
//            })
//            {
//                Image(systemName: "line.3.horizontal")
//                    .font(.title2)
//                    .foregroundColor(.black)
//            }
//            
//            Spacer()
//            
//            Text("University AI Advisor")
//                .font(.headline)
//                .fontWeight(.bold)
//                .foregroundColor(.black)
//            
//            Spacer()
//            NavigationLink(destination: ProfileView()) {
//                Image(systemName: "person.circle")
//                    .resizable()
//                    .frame(width: 32, height: 32)
//                    .foregroundColor(.blue)
//            }
////
////            Button(action: {
////
////            }) {
////                Image(systemName: "person.circle")
////                    .resizable()
////                    .frame(width: 32, height: 32)
////                    .foregroundColor(.blue)
////            }
//        }
//        .padding(.horizontal)
//        .padding(.bottom, 16)
//        .background(Color.main).shadow(radius: 8)
//    }
//}
//
//#Preview {
//    ChatSessionScreen()
//}

//import SwiftUI
//
//struct ChatSessionsScreen: View {
//    // 1. Add these State variables to manage the UI and Data
//    @State private var showMenu = false
//    @State private var activeSessionId: Int? = nil // nil means New Chat
//    @State private var messages: [ChatMessage] = [] // Holds the API messages
//    
//    var body: some View {
//        GeometryReader { geometry in
//            let width = geometry.size.width
//            let menuWidth = width * 0.75
//            
//            // Your exact ZStack layout
//            ZStack(alignment: .bottom) {
//                Color.main.ignoresSafeArea()
//                
//                VStack(spacing: 0) {
//                    appbar // Assuming you have this defined elsewhere
//                    
//                    ScrollView {
//                        VStack(spacing: 20) {
//                            // 2. Handle empty state vs loaded messages
//                            if activeSessionId == nil {
//                                Text("Start a new session with the Advisor")
//                                    .foregroundColor(.gray)
//                                    .padding(.top, 50)
//                            } else {
//                                ForEach(messages) { message in
//                                    MessageBubble(message: message, bubbleWidth: geometry.size.width * 0.75)
//                                }
//                            }
//                        }
//                        .padding()
//                        .padding(.bottom, 100)
//                    }
//                    // 3. This is the MAGIC line! It fetches data whenever the activeSessionId changes.
//                    .task(id: activeSessionId) {
//                        if let sessionId = activeSessionId {
//                            do {
//                                messages = try await ChatService.shared.fetchMessages(for: sessionId)
//                            } catch {
//                                print("Failed to load messages: \(error)")
//                            }
//                        } else {
//                            messages = [] // Clear screen for a new chat
//                        }
//                    }
//                    
//                    VoiceInputBar(sessionId: activeSessionId)
//                }
//            }
//            
//            // Your exact overlay logic
//            if showMenu {
//                Color.black.opacity(0.3)
//                    .ignoresSafeArea()
//                    .onTapGesture {
//                        withAnimation(.spring()) {
//                            showMenu = false
//                        }
//                    }
//                    .zIndex(1)
//            }
//            
//            // 4. Update the SideMenu to receive the closure
//            if showMenu {
//                SideMenu { selectedId in
//                    // Update the active ID and close the menu
//                    self.activeSessionId = selectedId
//                    
//                    withAnimation(.spring()) {
//                        self.showMenu = false
//                    }
//                }
//                .frame(width: menuWidth)
//                .transition(.move(edge: .leading))
//                .zIndex(2)
//            }
//        }
//        .animation(.spring(), value: showMenu)
//    }
//    
//    
//        var appbar : some View{
//            HStack {
//                Button(action: {
//                    withAnimation {
//                        showMenu.toggle()
//                    }
//                })
//                {
//                    Image(systemName: "line.3.horizontal")
//                        .font(.title2)
//                        .foregroundColor(.black)
//                }
//    
//                Spacer()
//    
//                Text("University AI Advisor")
//                    .font(.headline)
//                    .fontWeight(.bold)
//                    .foregroundColor(.black)
//    
//                Spacer()
//                NavigationLink(destination: ProfileView()) {
//                    Image(systemName: "person.circle")
//                        .resizable()
//                        .frame(width: 32, height: 32)
//                        .foregroundColor(.blue)
//                }
//    //
//    //            Button(action: {
//    //
//    //            }) {
//    //                Image(systemName: "person.circle")
//    //                    .resizable()
//    //                    .frame(width: 32, height: 32)
//    //                    .foregroundColor(.blue)
//    //            }
//            }
//            .padding(.horizontal)
//            .padding(.bottom, 16)
//            .background(Color.main).shadow(radius: 8)
//        }
//}



import SwiftUI

struct ChatSessionsScreen: View {
    @State private var showMenu = false
    @State private var activeSessionId: Int? = nil
    @State private var messages: [ChatMessage] = []
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let menuWidth = width * 0.75
            
            ZStack(alignment: .bottom) {
                Color.main.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    appbar
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            if activeSessionId == nil {
                                Text("Start a new session with the Advisor")
                                    .foregroundColor(.gray)
                                    .padding(.top, 50)
                            } else {
                                ForEach(messages) { message in
                                    MessageBubble(message: message, bubbleWidth: geometry.size.width * 0.75)
                                }
                            }
                        }
                        .padding()
                        .padding(.bottom, 100)
                    }
                    .task(id: activeSessionId) {
                        if let sessionId = activeSessionId {
                            do {
                                messages = try await ChatService.shared.fetchMessages(for: sessionId)
                            } catch {
                                print("Failed to load messages: \(error)")
                            }
                        } else {
                            messages = []
                        }
                    }
                    
                    // Note the $ sign here! This allows VoiceBar to update the ID automatically.
                    VoiceInputBar(sessionId: $activeSessionId, messages: $messages)
                }
            }
            
            if showMenu {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) { showMenu = false }
                    }
                    .zIndex(1)
            }
            
            if showMenu {
                SideMenu { selectedId in
                    // MANUALLY ADD NEW CHAT
                    if let selectedId = selectedId {
                        self.activeSessionId = selectedId
                    } else {
                        // User clicked "New Chat" (which passed nil)
                        startNewChat()
                    }
                    
                    withAnimation(.spring()) {
                        self.showMenu = false
                    }
                }
                .frame(width: menuWidth)
                .transition(.move(edge: .leading))
                .zIndex(2)
            }
        }
        .animation(.spring(), value: showMenu)
    }
    
    // MARK: - Manual Session Creation
    func startNewChat() {
        guard let studentId = UserDefaults.standard.string(forKey: "student_id") else { return }
        
        Task {
            do {
                let newId = try await ChatService.shared.createNewSession(studentId: studentId)
                await MainActor.run {
                    self.activeSessionId = newId
                    self.messages = [] // Clear the screen for the new chat
                }
            } catch {
                print("Failed to start new chat: \(error)")
            }
        }
    }
    
    // ... Keep your existing appbar variable below here ...
    var appbar : some View {
        HStack {
            Button(action: {
                withAnimation { showMenu.toggle() }
            }) {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundColor(.black)
            }
            Spacer()
            Text("University AI Advisor")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            Spacer()
            NavigationLink(destination: ProfileView()) {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
        .background(Color.main).shadow(radius: 8)
    }
}


