//
//  AcademicReportsViewModel.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 01/04/2026.
//

import Foundation
import Combine

enum ReportTab: String, CaseIterable {
    case offered = "Offered Courses"
    case dropped = "Dropped Courses"
    case transcript = "Transcript"
}

@MainActor
class AcademicReportsViewModel: ObservableObject {
    @Published var selectedTab: ReportTab = .offered {
        didSet {
            Task { await loadDataForActiveTab() }
        }
    }
    
    @Published var offeredCourses: [OfferedCourse] = []
    @Published var droppedCourses: [DroppedCourse] = []
    
    // Group transcript courses by session (e.g., "Fall 2023": [Course, Course])
    @Published var transcriptData: [String: [TranscriptCourse]] = [:]
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadDataForActiveTab() async {
        guard let studentId = UserDefaults.standard.string(forKey: "student_id") else {
            errorMessage = "User not logged in"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            switch selectedTab {
            case .offered:
                if offeredCourses.isEmpty {
                    offeredCourses = try await AcademicService.shared.fetchOfferedCourses(studentId: studentId)
                }
            case .dropped:
                if droppedCourses.isEmpty {
                    droppedCourses = try await AcademicService.shared.fetchDroppedCourses(studentId: studentId)
                }
            case .transcript:
                if transcriptData.isEmpty {
                    let allCourses = try await AcademicService.shared.fetchTranscript(studentId: studentId)
                    transcriptData = Dictionary(grouping: allCourses, by: { $0.session })
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // Helper to calculate Session GPA from the transcript API data
    func calculateGPA(for courses: [TranscriptCourse]) -> String {
        var totalPoints: Double = 0
        var totalCredits: Int = 0
        
        for course in courses {
            let points: Double
            switch course.grade.uppercased() {
            case "A": points = 4.0; case "A-": points = 3.67
            case "B+": points = 3.33; case "B": points = 3.0; case "B-": points = 2.67
            case "C+": points = 2.33; case "C": points = 2.0; case "C-": points = 1.67
            case "D+": points = 1.33; case "D": points = 1.0; case "F": points = 0.0
            default: continue
            }
            totalPoints += points * Double(course.creditHours)
            totalCredits += course.creditHours
        }
        
        if totalCredits == 0 { return "0.00" }
        return String(format: "%.2f", totalPoints / Double(totalCredits))
    }
}
