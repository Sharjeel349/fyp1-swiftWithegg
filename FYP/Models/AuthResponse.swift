import Foundation
import Combine

struct AuthResponse: Codable {
    let userId: Int
    let studentId: String?
    let name: String
    let role: String
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case studentId = "student_id"
        case name, role, message
    }
}
