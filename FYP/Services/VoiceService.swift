//
//  VoiceService.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 21/04/2026.


import Foundation
import Combine

// 1. The model perfectly matching your FastAPI JSON response

class VoiceService {
    static let shared = VoiceService()
    private let network = NetworkManager() // Your centralized API manager
    
    // 2. Function to upload the audio and receive the JSON response
    func uploadVoice(sessionId: Int, fileData: Data, fileName: String, emotion: String) async throws -> VoiceResponse {
        
        // Define the endpoint (Make sure it matches your Python route! e.g., "/{session_id}/voice")
        let endpoint = "/\(sessionId)/voice"
        let additionalParameters = [
                    "emotion": emotion
                ]
        
        // Use NetworkManager to upload the data and get the JSON data back
//        let responseData = try await network.uploadFile(url: endpoint, fileData: fileData, fileName: fileName)
        let responseData = try await network.uploadFile(
                    url: endpoint,
                    fileData: fileData,
                    fileName: fileName,
                    parameters: additionalParameters // 🟢 NEW
                )
        
        // Decode the returned JSON into your Swift Struct
        let decoder = JSONDecoder()
        let voiceResponse = try decoder.decode(VoiceResponse.self, from: responseData)
        
        return voiceResponse
    }
}

