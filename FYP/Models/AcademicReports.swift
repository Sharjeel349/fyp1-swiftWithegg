//
//  AcademicReports.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 01/04/2026.
//

import Foundation
import Combine

struct OfferedCourse: Codable, Identifiable {
    var id: String { courseId } // Using courseId as the unique ID
    let courseId: String
    let title: String
    let session: String
    let teacherName: String
    let sectionCode: String
    
    enum CodingKeys: String, CodingKey {
        case courseId = "course_id"
        case title, session
        case teacherName = "teacher_name"
        case sectionCode = "section_code"
    }
}

struct DroppedCourse: Codable, Identifiable {
    var id: String { courseId }
    let courseId: String
    let title: String
    let session: String
    let teacherName: String
    let grade: String
    
    enum CodingKeys: String, CodingKey {
        case courseId = "course_id"
        case title, session
        case teacherName = "teacher_name"
        case grade
    }
}

struct TranscriptCourse: Codable, Identifiable {
    var id: String { courseId }
    let session: String
    let courseId: String
    let title: String
    let grade: String
    let creditHours: Int
    
    enum CodingKeys: String, CodingKey {
        case session
        case courseId = "course_id"
        case title, grade
        case creditHours = "credit_hours"
    }
}
