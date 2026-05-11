////
////  VoiceBar.swift
////  FYP
////
////  Created by Sharjeel Ahmed on 12/02/2026.
////
//import SwiftUI
//
//struct VoiceInputBar: View {
//    var body: some View {
//        HStack {
//            // Brain Icon
//            Image(systemName: "brain.head.profile")
//                .font(.system(size: 24))
//                .foregroundColor(.white)
//                .padding(.leading, 30)
//            
//            Spacer()
//            
//            // Mic Button (Centered)
//            ZStack {
//                Circle()
//                    .fill(Color.white)
//                    .frame(width: 60, height: 60)
//                    .shadow(radius: 4)
//                Button {
//                } label:
//                {
//                    Image(systemName: "mic")
//                        .font(.title2)
//                        .foregroundColor(.black)
//                }
//            }
//            // Slight pop-up effect
//            
//            Spacer()
//            
//            // Empty view to balance the layout centered
//            Color.clear
//                .frame(width: 24, height: 24)
//                .padding(.trailing, 30)
//        }
//        .frame(height: 80)
//        .background(
//            RoundedRectangle(cornerRadius: 20)
//                .fill(
//                    LinearGradient(
//                        gradient: Gradient(colors: [Color.gradientStart, Color.gradientend]),
//                        startPoint: .top,
//                        endPoint: .bottom
//                    )
//                )
//        )
//        .padding(.horizontal)
//        .padding(.bottom,5)
//        .padding(.top)
//        .background(
//           Rectangle()
//                .fill(
//                    .main
//                )
//        )
//        .shadow(radius: 2, x: 0,y: -2)
//        
//        
//    }
//}
//
//  VoiceBar.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 12/02/2026.
//

//import SwiftUI
//
//struct VoiceInputBar: View {
//    // Moved outside of 'body' so it doesn't get destroyed on UI updates
//    @StateObject private var vm = VoiceViewModel()
//    let sessionId: Int?
//    
//    var body: some View {
//        VStack(spacing: 5) {
//            HStack {
//                // Brain Icon
//                Image(systemName: "brain.head.profile")
//                    .font(.system(size: 24))
//                    .foregroundColor(.white)
//                    .padding(.leading, 30)
//                
//                Spacer()
//                
//                // Mic Button (Centered)
//                Button {
//                    vm.toggleRecording()
//                } label: {
//                    ZStack {
//                        Circle()
//                            .fill(vm.isRecording ? Color.red : Color.white)
//                            .frame(width: 60, height: 60)
//                            .shadow(radius: 4)
//                        
//                        Image(systemName: vm.isRecording ? "stop.fill" : "mic")
//                            .font(.title2)
//                            .foregroundColor(vm.isRecording ? .white : .black)
//                    }
//                }
//                .offset(y: 0) // Slight pop-up effect
//                
//                Spacer()
//                
//                // Empty view to balance the layout centered
//                Color.clear
//                    .frame(width: 24, height: 24)
//                    .padding(.trailing, 30)
//            }
//            .frame(height: 80)
//            .background(
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(
//                        LinearGradient(
//                            gradient: Gradient(colors: [Color.gradientStart, Color.gradientend]),
//                            startPoint: .top,
//                            endPoint: .bottom
//                        )
//                    )
//            )
//            
//            // Timer Display (Only shows when recording)
//            if vm.isRecording {
//                Text(String(format: "%02d:%02d", vm.secondsElapsed / 60, vm.secondsElapsed % 60))
//                    .font(.system(.caption, design: .monospaced))
//                    .foregroundColor(.black)
//                    .padding(.bottom, 5)
//            }
//        }
//        .padding(.horizontal)
//        .padding(.bottom, 5)
//        .padding(.top)
//        .background(
//            Rectangle()
//                .fill(Color.main)
//        )
//        .shadow(radius: 2, x: 0, y: -2)
//    }
//}


import SwiftUI
import Combine

struct VoiceInputBar: View {
    // Moved outside of 'body' so it doesn't get destroyed on UI updates
    @StateObject private var vm = VoiceViewModel()
    @ObservedObject var museManager = MuseManager.shared
    @Binding var sessionId: Int?
    @Binding var messages: [ChatMessage]
    
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Button(action: {
                    if museManager.isConnected {
                
                        museManager.disconnectHeadset()
                    }
                    else if !museManager.isConnecting {
                        // 2. If it is NOT connected and NOT currently trying to connect, connect it!
                        museManager.connectHeadset()
                    }
                    // (If it is currently in the middle of connecting, clicking does nothing so it doesn't crash)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 24))
                            // The magic color logic: Green if connected, Orange if connecting, White if idle
                            .foregroundColor(museManager.isConnected ? .green : (museManager.isConnecting ? .orange : .white))
                        
                        // This text will dynamically appear only while it is searching for the headset
                        if museManager.isConnecting {
                            Text("Connecting EEG...")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.leading, 30) // Kept your original padding
                }
                // Optional: Add a subtle animation so the color changes smoothly
                .animation(.easeInOut, value: museManager.isConnected)
                .animation(.easeInOut, value: museManager.isConnecting)
                
                Spacer()
                
                // Mic Button (Centered)
                Button {
                    vm.toggleRecording()
                } label: {
                    ZStack {
                        Circle()
                            .fill(vm.isRecording ? Color.red : Color.white)
                            .frame(width: 60, height: 60)
                            .shadow(radius: 4)
                        
                        Image(systemName: vm.isRecording ? "stop.fill" : "mic")
                            .font(.title2)
                            .foregroundColor(vm.isRecording ? .white : .black)
                    }
                }
                .offset(y: 0) // Slight pop-up effect
                
                Spacer()
                
                // Empty view to balance the layout centered
                Color.clear
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 30)
            }
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gradientStart, Color.gradientend]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            
            // Dynamic Status Display Below the Bar
            if vm.isRecording {
                // Show Timer while recording
                Text(String(format: "%02d:%02d", vm.secondsElapsed / 60, vm.secondsElapsed % 60))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.black)
                    .padding(.bottom, 5)
            } else if vm.isUploading {
                // Show Loading Spinner while waiting for FastAPI
                HStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    Text("Processing...")
                        .font(.caption)
                        .foregroundColor(.black)
                }
                .padding(.bottom, 5)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 5)
        .padding(.top)
        .background(
            Rectangle()
                .fill(Color.main)
        )
        .shadow(radius: 2, x: 0, y: -2)
        // 1. Pass the initial ID when the view loads
        .onAppear {
                    vm.sessionId = sessionId
                }
        .onChange(of: vm.newVoiceResponse) {
                    // Read directly from the ViewModel!
                    guard let response = vm.newVoiceResponse else { return }
                    
                    // Grab the current time
                    let formatter = DateFormatter()
                    formatter.dateFormat = "hh:mm a"
                    let timeStr = formatter.string(from: Date())
                    
                    // Create the User Bubble
            let userMessage = ChatMessage(
                text: response.userText,
                time: timeStr,
                isCurrentUser: true,
                textColor: response.emotion=="Neutral" ? "black" :
                    response.emotion=="CALM" ? "green" : "red")
                    
                    // Create the Bot Bubble
                    let botMessage = ChatMessage(text: response.botText, time: timeStr, isCurrentUser: false, textColor: "black")
                    
                    // Push them to the screen instantly!
                    withAnimation {
                        messages.append(userMessage)
                        messages.append(botMessage)
                    }
                }
        
        .onChange(of: sessionId) {
                    if vm.sessionId != sessionId {
                        vm.sessionId = sessionId
                    }
                }
                
                // 4. Update the main screen if ViewModel creates a session (0 arguments)
                .onChange(of: vm.sessionId) {
                    if sessionId != vm.sessionId {
                        sessionId = vm.sessionId
                    }
                }
    }
}



