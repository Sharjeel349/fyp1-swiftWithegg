////
////  VoiceViewModel.swift
////  FYP
////
////  Created by Sharjeel Ahmed on 21/04/2026.
////
//import SwiftUI
//import Foundation
//import AVFoundation
//import Combine
//@MainActor // Ensures all UI updates and audio playback happen on the main thread
//class VoiceViewModel: NSObject, ObservableObject {
//    @Published var isRecording = false
//    @Published var secondsElapsed = 0
//    @Published var isUploading = false // Use this to show a loading spinner in your UI!
//    
//    // The active session ID passed down from your UI
//    var sessionId: Int?
//    @Published var newVoiceResponse: VoiceResponse? = nil
//    
//    private var audioRecorder: AVAudioRecorder?
//    private var timer: Timer?
//    private var audioURL: URL?
//    private var audioPlayer: AVPlayer? // Used to play the bot's voice back
//
//    func toggleRecording() {
//        if isRecording {
//            stopRecording()
//        } else {
//            startRecording()
//        }
//    }
//
//    private func startRecording() {
//        let session = AVAudioSession.sharedInstance()
//        try? session.setCategory(.playAndRecord, mode: .default)
//        try? session.setActive(true)
//
//        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        audioURL = path.appendingPathComponent("input.m4a")
//
//        let settings: [String: Any] = [
//            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//            AVSampleRateKey: 16000,
//            AVNumberOfChannelsKey: 1,
//            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//        ]
//
//        audioRecorder = try? AVAudioRecorder(url: audioURL!, settings: settings)
//        audioRecorder?.record()
//        
//        isRecording = true
//        startTimer()
//    }
//
//    private func stopRecording() {
//        audioRecorder?.stop()
//        isRecording = false
//        stopTimer()
//        
//        uploadVoice() // Trigger the API call
//    }
//
//    // MARK: - API Integration
//    private func uploadVoice() {
//            guard let url = audioURL, let data = try? Data(contentsOf: url) else { return }
//            
//            isUploading = true
//            
//            Task {
//                do {
//                    // --- THE AUTOMATIC CREATION LOGIC ---
//                    var activeId = self.sessionId
//                    
//                    // If the user started talking without clicking "New Chat" first
//                    if activeId == nil {
//                        // 1. Grab the logged-in student ID
//                        guard let studentId = UserDefaults.standard.string(forKey: "student_id") else {
//                            print("Error: No student ID found. Cannot create session.")
//                            await MainActor.run { isUploading = false }
//                            return
//                        }
//                        
//                        // 2. Automatically create the session in PostgreSQL
//                        activeId = try await ChatService.shared.createNewSession(studentId: studentId)
//                        
//                        // 3. Update the ViewModel (which updates the UI via the Binding we just made)
//                        await MainActor.run {
//                            self.sessionId = activeId
//                        }
//                    }
//                    
//                    guard let finalSessionId = activeId else { return }
//                    
//                    // --- PROCEED WITH VOICE UPLOAD ---
//                    let response = try await VoiceService.shared.uploadVoice(
//                        sessionId: finalSessionId,
//                        fileData: data,
//                        fileName: "user_voice.m4a"
//                    )
//                    
//                    // 🟢 NEW: Save both messages to the PostgreSQL Database
//                    try? await ChatService.shared.saveMessage(sessionId: finalSessionId, sender: "User", text: response.userText, voiceFile: response.userAudioUrl)
//                    
//                    try? await ChatService.shared.saveMessage(sessionId: finalSessionId, sender: "Bot", text: response.botText, voiceFile: response.botAudioUrl)
//                    
//                    // Play the Advisor's response
//                    playBotAudio(path: response.botAudioUrl)
//                    
//                    // 🟢 NEW: Tell the UI to draw the bubbles and hide the spinner
//                    await MainActor.run {
//                        self.isUploading = false
//                        self.newVoiceResponse = response // This triggers the .onChange in VoiceInputBar!
//                    }
//                    
//                } catch {
//                    print("Failed to upload voice: \(error.localizedDescription)")
//                    await MainActor.run { isUploading = false }
//                }
//            }
//        }
//    private func playBotAudio(path: String) {
//        // Combine your base URL with the static path from FastAPI
//        // Note: Change 127.0.0.1 to your Mac's Wi-Fi IP if testing on a physical iPhone
//        let fullURLString = "http://127.0.0.1:8000" + path
//        
//        guard let url = URL(string: fullURLString) else { return }
//        
//        let playerItem = AVPlayerItem(url: url)
//        audioPlayer = AVPlayer(playerItem: playerItem)
//        audioPlayer?.play()
//    }
//
//    // MARK: - Timer Logic
//    private func startTimer() {
//        secondsElapsed = 0
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//            self.secondsElapsed += 1
//        }
//    }
//    
//    private func stopTimer() {
//        timer?.invalidate()
//    }
//}

//
//  VoiceViewModel.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 21/04/2026.
//

import SwiftUI
import Foundation
import AVFoundation
import Combine

@MainActor // Ensures all UI updates and audio playback happen on the main thread
class VoiceViewModel: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var secondsElapsed = 0
    @Published var isUploading = false // Use this to show a loading spinner in your UI!
    
    // The active session ID passed down from your UI
    var sessionId: Int?
    @Published var newVoiceResponse: VoiceResponse? = nil
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var audioURL: URL?
    private var audioPlayer: AVPlayer? // Used to play the bot's voice back

    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default)
        try? session.setActive(true)

        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        audioURL = path.appendingPathComponent("input.m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        audioRecorder = try? AVAudioRecorder(url: audioURL!, settings: settings)
        audioRecorder?.record()
        
        isRecording = true
        startTimer()
        
        // 🟢 1. START EEG STREAM (If connected)
        if MuseManager.shared.isConnected {
            MuseManager.shared.startStreamingData()
        }
    }

    private func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        stopTimer()
        
        // 🟢 2. CAPTURE THE EXACT EMOTIONAL STATE
        let capturedEmotion = MuseManager.shared.currentState
        print("Captured Emotion for API: \(capturedEmotion)")
        
        // 🟢 3. PAUSE EEG STREAM (To save battery & processing power)
        if MuseManager.shared.isConnected {
            MuseManager.shared.pauseStreamingData()
        }
        
        // Trigger the API call and pass the emotion!
        uploadVoice(emotion: capturedEmotion)
    }

    // MARK: - API Integration
    private func uploadVoice(emotion: String) { // 🟢 Accept emotion here
        guard let url = audioURL, let data = try? Data(contentsOf: url) else { return }
            
        isUploading = true
            
        Task {
            do {
                // --- THE AUTOMATIC CREATION LOGIC ---
                var activeId = self.sessionId
                
                // If the user started talking without clicking "New Chat" first
                if activeId == nil {
                    // 1. Grab the logged-in student ID
                    guard let studentId = UserDefaults.standard.string(forKey: "student_id") else {
                        print("Error: No student ID found. Cannot create session.")
                        await MainActor.run { isUploading = false }
                        return
                    }
                    
                    // 2. Automatically create the session in PostgreSQL
                    activeId = try await ChatService.shared.createNewSession(studentId: studentId)
                    
                    // 3. Update the ViewModel (which updates the UI via the Binding we just made)
                    await MainActor.run {
                        self.sessionId = activeId
                    }
                }
                
                guard let finalSessionId = activeId else { return }
                
                // --- PROCEED WITH VOICE UPLOAD ---
                let response = try await VoiceService.shared.uploadVoice(
                    sessionId: finalSessionId,
                    fileData: data,
                    fileName: "user_voice.m4a",
                    emotion: emotion // 🟢 Pass the emotion to your Service!
                )
                
                // Save both messages to the PostgreSQL Database
//                try? await ChatService.shared.saveMessage(sessionId: finalSessionId, sender: "User", text: response.userText, voiceFile: response.userAudioUrl)
//                
//                try? await ChatService.shared.saveMessage(sessionId: finalSessionId, sender: "Bot", text: response.botText, voiceFile: response.botAudioUrl)
                
                // Play the Advisor's response
                playBotAudio(path: response.botAudioUrl)
                
                // Tell the UI to draw the bubbles and hide the spinner
                await MainActor.run {
                    self.isUploading = false
                    self.newVoiceResponse = response // This triggers the .onChange in VoiceInputBar!
                }
                
            } catch {
                print("Failed to upload voice: \(error.localizedDescription)")
                await MainActor.run { isUploading = false }
            }
        }
    }
    
    private func playBotAudio(path: String) {
       
        let network = NetworkManager()
        let fullURLString = network.baseURL + path
        
        guard let url = URL(string: fullURLString) else { return }
        
        let playerItem = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: playerItem)
        audioPlayer?.play()
    }

    // MARK: - Timer Logic
    private func startTimer() {
        secondsElapsed = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.secondsElapsed += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
    }
}
