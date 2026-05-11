//
//  AcademicService.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 01/04/2026.
//

import Foundation
import Combine

class AcademicService {
    static let shared = AcademicService()
    private let network = NetworkManager() // Assuming your NetworkManager is available
    
    func fetchOfferedCourses(studentId: String) async throws -> [OfferedCourse] {
        let data = try await network.request(url: "/student/\(studentId)/offered-courses", method: "GET")
        return try JSONDecoder().decode([OfferedCourse].self, from: data)
    }
    
    func fetchDroppedCourses(studentId: String) async throws -> [DroppedCourse] {
        let data = try await network.request(url: "/student/\(studentId)/dropped-courses", method: "GET")
        return try JSONDecoder().decode([DroppedCourse].self, from: data)
    }
    
    func fetchTranscript(studentId: String) async throws -> [TranscriptCourse] {
        let data = try await network.request(url: "/student/\(studentId)/transcript", method: "GET")
        return try JSONDecoder().decode([TranscriptCourse].self, from: data)
    }
}
