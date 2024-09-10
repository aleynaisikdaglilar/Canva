//
//  CanvasViewController.swift
//  Canva
//
//  Created by Aleyna Işıkdağlılar on 9.09.2024.
//

import UIKit

final class CanvasViewController: UIViewController {
    
    private var selectedImageView: UIImageView?
    private var imageViewFrames: [UIImageView: CGRect] = [:]
    private var overlayView: UIView?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        return scrollView
    }()
    
    private let canvasView: UIView = {
        let canvasView = UIView()
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.backgroundColor = .white
        return canvasView
    }()
    
    private let addButton: UIButton = {
        let addButton = UIButton()
        addButton.setTitle("+", for: .normal)
        addButton.backgroundColor = .blue
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.cornerRadius = 25
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(showImagePicker), for: .touchUpInside)
        return addButton
    }()
    
    @objc private func showImagePicker() {
        let imagePickerVC = ImagePickerViewController()
        imagePickerVC.delegate = self
        present(imagePickerVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCanvasTap))
        canvasView.addGestureRecognizer(tapGesture)
    }
    
    private func addConstraints() {
        view.addSubview(scrollView)
        scrollView.addSubview(canvasView)
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            canvasView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            canvasView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            canvasView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1.2), // Scaled width
            canvasView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 1.2), // Scaled height
            
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 50),
            addButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        let lineWidth: CGFloat = 1.0
        let numberOfLines = 2
        let scaledCanvasWidth = view.frame.width * 1.2 // Calculate scaled width
        
        for i in 1...numberOfLines {
            let line = UIView()
            line.backgroundColor = .gray
            canvasView.addSubview(line)
            line.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                line.topAnchor.constraint(equalTo: canvasView.topAnchor),
                line.bottomAnchor.constraint(equalTo: canvasView.bottomAnchor),
                line.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor, constant: scaledCanvasWidth / 3 * CGFloat(i)),
                line.widthAnchor.constraint(equalToConstant: lineWidth)
            ])
        }
    }
    
    
    @objc private func handleCanvasTap() {
        removeOverlay()
        selectedImageView = nil
    }
    
    private func removeOverlay() {
        overlayView?.removeFromSuperview()
        overlayView = nil
    }
    
    private func makeImageViewMovable(_ imageView: UIImageView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        imageView.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        imageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let imageView = gesture.view as? UIImageView else { return }
        
        if gesture.state == .began {
            selectedImageView = imageView
            addOverlay(to: imageView)
        }
        
        let translation = gesture.translation(in: canvasView)
        imageView.frame = imageView.frame.offsetBy(dx: translation.x, dy: translation.y)
        gesture.setTranslation(.zero, in: canvasView)
        
        if gesture.state == .changed || gesture.state == .ended {
            imageViewFrames[imageView] = imageView.frame
            
            if selectedImageView == imageView {
                updateOverlayFrame(for: imageView)
            }
        }
    }
    
    @objc private func handleImageTap(_ gesture: UITapGestureRecognizer) {
        guard let imageView = gesture.view as? UIImageView else { return }
        
        if selectedImageView != imageView {
            selectedImageView = imageView
            addOverlay(to: imageView)
        }
    }
    
    private func addOverlay(to imageView: UIImageView) {
        removeOverlay()
        
        let padding: CGFloat = 5.0
        
        
        overlayView = UIView(frame: imageView.frame.insetBy(dx: -padding, dy: -padding))
        overlayView?.backgroundColor = UIColor.cyan.withAlphaComponent(0.3)
        overlayView?.isUserInteractionEnabled = false
        
        if let overlay = overlayView {
            canvasView.insertSubview(overlay, aboveSubview: imageView)
        }
    }
    
    private func updateOverlayFrame(for imageView: UIImageView) {
        
        let padding: CGFloat = 5.0
        
        overlayView?.frame = imageView.frame.insetBy(dx: -padding, dy: -padding)
    }
}

extension CanvasViewController: ImagePickerDelegate {
    func didSelectImage(_ image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.isUserInteractionEnabled = true
        canvasView.addSubview(imageView)
        
        makeImageViewMovable(imageView)
        
        let initialFrame = CGRect(x: (canvasView.bounds.width - 100) / 2,
                                  y: (canvasView.bounds.height - 100) / 2,
                                  width: 100,
                                  height: 100)
        
        imageView.frame = initialFrame
        imageViewFrames[imageView] = initialFrame
        
        selectedImageView = imageView
        addOverlay(to: imageView)
    }
}
