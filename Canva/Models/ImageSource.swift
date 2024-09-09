//
//  ImageSource.swift
//  Canva
//
//  Created by Aleyna Işıkdağlılar on 9.09.2024.
//

import Foundation

struct ImageSource: Codable {
    let original: String
    let large2x: String
    let large: String
    let medium: String
    let small: String
    let portrait: String
    let landscape: String
    let tiny: String
}
