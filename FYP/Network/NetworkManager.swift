//
//  NetworkManager.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 31/03/2026.
//

import Foundation
import Combine

class NetworkManager {
    let baseURL = "http://192.168.0.110:8000/api"
    //let baseURL = "http://10.19.62.23:8000/api"

    
    
    func request(url: String, method: String, body: [String: Any]? = nil) async throws -> Data {
        guard let fullurl = URL(string: baseURL + url) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: fullurl)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Adding body data here for POST method call
        if let body = body {
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)
                }
        
        //calling the API here
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            let detail = errorData?["detail"] as? String ?? "Server error occurred"
            
            throw NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: detail])
        }
        return data
        }
    
    
    func uploadFile(url: String, fileData: Data, fileName: String, mimeType: String = "audio/m4a", parameters: [String: String]? = nil) async throws -> Data {
            guard let fullurl = URL(string: baseURL + url) else {
                throw URLError(.badURL)
            }
            
            var request = URLRequest(url: fullurl)
            request.httpMethod = "POST"
            
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            // Constructing the multipart body
            var body = Data()
        if let parameters = parameters {
                    for (key, value) in parameters {
                        body.append("--\(boundary)\r\n".data(using: .utf8)!)
                        body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                        body.append("\(value)\r\n".data(using: .utf8)!)
                    }
                }
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"audio_file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
            body.append(fileData)
            body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            
            request.httpBody = body
            
            // Calling the API
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                let detail = errorData?["detail"] as? String ?? "Server error occurred"
                throw NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: detail])
            }
            
            return data
        }
}
