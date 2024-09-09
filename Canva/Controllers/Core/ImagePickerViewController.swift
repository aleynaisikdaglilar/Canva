//
//  ImagePickerViewController.swift
//  Canva
//
//  Created by Aleyna Işıkdağlılar on 9.09.2024.
//

import UIKit

protocol ImagePickerDelegate: AnyObject {
    func didSelectImage(_ image: UIImage)
}

class ImagePickerViewController: UIViewController {
    
    weak var delegate: ImagePickerDelegate?
    private let viewModel = PexelsViewModel()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.register(ImagePickerCollectionViewCell.self, forCellWithReuseIdentifier: ImagePickerCollectionViewCell.cellIdentifier)
        return collectionView
    }()
    
    private func addConstraints() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 3),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 3),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -3)
        ])
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 120, height: 120)
        }
    }
    
    private func loadImages() {
        viewModel.loadPhotos {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        
        addConstraints()
        loadImages()
    }
}

extension ImagePickerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImagePickerCollectionViewCell.cellIdentifier, for: indexPath) as! ImagePickerCollectionViewCell
        let photo = viewModel.photos[indexPath.item]
        cell.configure(with: photo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = viewModel.photos[indexPath.item]
        if let url = URL(string: photo.src.original), let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
            delegate?.didSelectImage(image)
            dismiss(animated: true, completion: nil)
        }
    }
}
