//
//  StudentProfile.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 01/04/2026.
//

import Foundation
import Combine

struct StudentProfile: Codable {
    let name: String
    let registrationNo: String
    let cgpa: Double
    let semester: String
    let sectionCode: String
    let advisorName: String
    let advisorDesignation: String
    
    // Maps your Python snake_case to Swift camelCase
    enum CodingKeys: String, CodingKey {
        case name
        case registrationNo = "registration_no"
        case cgpa
        case semester
        case sectionCode = "section_code"
        case advisorName = "advisor_name"
        case advisorDesignation = "advisor_designation"
    }
}
