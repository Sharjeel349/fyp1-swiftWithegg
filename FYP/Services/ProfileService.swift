//
//  ProfileService.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 01/04/2026.
//

import Foundation
import Combine

class ProfileService {
    static let shared = ProfileService()
    private let network = NetworkManager()
    
    func fetchProfile(studentId: String) async throws -> StudentProfile {
        // Calling your GET endpoint
        let data = try await network.request(url: "/student/\(studentId)/profile", method: "GET")
        
        // Decode the data into your struct
        let profile = try JSONDecoder().decode(StudentProfile.self, from: data)
        return profile
    }
}
