//
//  PexelsService.swift
//  Canva
//
//  Created by Aleyna Işıkdağlılar on 9.09.2024.
//

import Foundation

final class PexelsService {
    private let apiKey = "0rWBGhCRoFiVbbq4duycTLqsvROdrjKqHdGkciUBYdubEU21DoqNC6yY"
    private let baseURL = "https://api.pexels.com/v1/curated"
    
    func fetchPhotos(completion: @escaping (Result<PexelsResponse, NetworkError>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(.invalidResponse))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            if httpResponse.statusCode == 401 {
                completion(.failure(.unauthorized))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            if let rawString = String(data: data, encoding: .utf8) {
                print("Raw Response Data: \(rawString)")
            }
            
            do {
                let response = try JSONDecoder().decode(PexelsResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.decodingError))
            }
        }
        
        task.resume()
    }
}
