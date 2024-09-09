//
//  Photo.swift
//  Canva
//
//  Created by Aleyna Işıkdağlılar on 9.09.2024.
//

import Foundation

struct Photo: Codable {
    let id: Int
    let width: Int
    let height: Int
    let url: String
    let photographer: String
    let photographerUrl: String
    let photographerId: Int
    let avgColor: String?
    let src: ImageSource
    let liked: Bool
    let alt: String
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, url, photographer
        case photographerUrl = "photographer_url"
        case photographerId = "photographer_id"
        case avgColor = "avg_color"
        case src, liked, alt
    }
}
