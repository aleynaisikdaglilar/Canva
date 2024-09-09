//
//  Error.swift
//  Canva
//
//  Created by Aleyna Işıkdağlılar on 9.09.2024.
//

import Foundation

enum NetworkError: LocalizedError {
    
    case invalidResponse
    case invalidData
    case decodingError
    case unauthorized
    
    var errorDescription: String? {
        
        switch self {
        case .invalidResponse:
            return "Invalid Response"
        case .invalidData:
            return "Invalid Data"
        case.decodingError:
            return "Decoding Error"
        case .unauthorized:
            return "Unauthorized"
        }
    }
}
