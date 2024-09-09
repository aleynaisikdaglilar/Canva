//
//  PexelsResponse.swift
//  Canva
//
//  Created by Aleyna Işıkdağlılar on 9.09.2024.
//

import Foundation

struct PexelsResponse: Codable {
    let page: Int?
    let perPage: Int?
    let photos: [Photo]?
    let nextPage: String?
    
    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case photos
        case nextPage = "next_page"
    }
}




