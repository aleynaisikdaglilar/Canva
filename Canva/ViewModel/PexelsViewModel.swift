//
//  ImageViewModel.swift
//  Canva
//
//  Created by Aleyna Işıkdağlılar on 9.09.2024.
//

import Foundation

final class PexelsViewModel {
    private let service = PexelsService()
    var photos: [Photo] = []
    var error: NetworkError?
    
    func loadPhotos(completion: @escaping () -> Void) {
        service.fetchPhotos { [weak self] result in
            switch result {
            case .success(let response):
                self?.photos = response.photos ?? []
                self?.error = nil
            case .failure(let networkError):
                self?.error = networkError
                self?.photos = []
            }
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
