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
    private var lines: [UIView] = []
    var imageViews: [UIImageView] = []
    var guideLines: [CAShapeLayer] = []
    let snapThreshold: CGFloat = 5.0
    
    private var horizontalCenterLine: UIView?
    private var verticalCenterLine: UIView?
    
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
            
            canvasView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1.2),
            canvasView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 1.2),
            
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 50),
            addButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        addFixedLines()
    }
    
    private func addFixedLines() {
        let lineWidth: CGFloat = 1.0
        let numberOfLines = 2
        let scaledCanvasWidth = view.frame.width * 1.2
        
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
            lines.append(line)
        }
    }
    
    @objc private func handleCanvasTap() {
        removeOverlay()
        selectedImageView = nil
        hideCenterLines()
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
        
        let draggedView = imageView
        let newTranslation = gesture.translation(in: self.view)
        draggedView.center = CGPoint(x: draggedView.center.x + newTranslation.x, y: draggedView.center.y + newTranslation.y)
        gesture.setTranslation(.zero, in: self.view)
        
        if gesture.state == .changed || gesture.state == .ended {
            imageViewFrames[imageView] = imageView.frame
            
            if selectedImageView == imageView {
                updateOverlayFrame(for: imageView)
            }
            
            checkIntersection(for: imageView)
            checkImageViewCenter(for: imageView)
            
            updateGuideLines(for: draggedView)
            snapToGuideLines(draggedView)
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
        
        overlayView = UIView(frame: imageView.frame)
        overlayView?.backgroundColor = UIColor.cyan.withAlphaComponent(0.3)
        overlayView?.isUserInteractionEnabled = false
        
        if let overlay = overlayView {
            canvasView.insertSubview(overlay, aboveSubview: imageView)
        }
    }
    
    private func updateOverlayFrame(for imageView: UIImageView) {
        overlayView?.frame = imageView.frame
    }
    
    private func checkIntersection(for imageView: UIImageView) {
        guard let overlayFrame = overlayView?.superview?.convert(overlayView!.frame, to: canvasView) else { return }
        
        var isIntersecting = false
        
        for line in lines {
            if overlayFrame.intersects(line.frame) {
                line.backgroundColor = .yellow
                isIntersecting = true
            } else if !isIntersecting {
                line.backgroundColor = .gray
            }
        }
    }
    
    private func checkImageViewCenter(for imageView: UIImageView) {
        let imageViewCenter = imageView.center
        let canvasViewCenter = CGPoint(x: canvasView.bounds.midX, y: canvasView.bounds.midY)
        
        if abs(imageViewCenter.y - canvasViewCenter.y) <= 1.0 {
            showHorizontalCenterLine()
        } else {
            hideHorizontalCenterLine()
        }
        
        if abs(imageViewCenter.x - canvasViewCenter.x) <= 1.0 {
            showVerticalCenterLine()
        } else {
            hideVerticalCenterLine()
        }
    }
    
    private func showHorizontalCenterLine() {
        if horizontalCenterLine == nil {
            let line = UIView()
            line.backgroundColor = .yellow
            canvasView.addSubview(line)
            line.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                line.centerYAnchor.constraint(equalTo: canvasView.centerYAnchor),
                line.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor),
                line.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor),
                line.heightAnchor.constraint(equalToConstant: 2.0)
            ])
            horizontalCenterLine = line
        }
        horizontalCenterLine?.isHidden = false
    }
    
    private func hideHorizontalCenterLine() {
        horizontalCenterLine?.isHidden = true
    }
    
    private func showVerticalCenterLine() {
        if verticalCenterLine == nil {
            let line = UIView()
            line.backgroundColor = .yellow
            canvasView.addSubview(line)
            line.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                line.centerXAnchor.constraint(equalTo: canvasView.centerXAnchor),
                line.topAnchor.constraint(equalTo: canvasView.topAnchor),
                line.bottomAnchor.constraint(equalTo: canvasView.bottomAnchor),
                line.widthAnchor.constraint(equalToConstant: 2.0)
            ])
            verticalCenterLine = line
        }
        verticalCenterLine?.isHidden = false
    }
    
    private func hideVerticalCenterLine() {
        verticalCenterLine?.isHidden = true
    }
    
    private func hideCenterLines() {
        hideHorizontalCenterLine()
        hideVerticalCenterLine()
    }
    
    // Snap to guide lines function
    func snapToGuideLines(_ draggedView: UIImageView) {
        let draggedFrame = draggedView.frame
        
        for imageView in imageViews where imageView != draggedView {
            let otherFrame = imageView.frame
            
            // Snapping to horizontal guide lines
            if abs(draggedFrame.minY - otherFrame.minY) < snapThreshold {
                draggedView.frame.origin.y = otherFrame.minY
            } else if abs(draggedFrame.maxY - otherFrame.maxY) < snapThreshold {
                draggedView.frame.origin.y = otherFrame.maxY - draggedFrame.height
            } else if abs(draggedFrame.midY - otherFrame.midY) < snapThreshold {
                draggedView.center.y = otherFrame.midY
            } else if abs(draggedFrame.minY - otherFrame.maxY) < snapThreshold {
                draggedView.frame.origin.y = otherFrame.maxY
            } else if abs(draggedFrame.maxY - otherFrame.minY) < snapThreshold {
                draggedView.frame.origin.y = otherFrame.minY - draggedFrame.height
            }
            
            // Snapping to vertical guide lines
            if abs(draggedFrame.minX - otherFrame.minX) < snapThreshold {
                draggedView.frame.origin.x = otherFrame.minX
            } else if abs(draggedFrame.maxX - otherFrame.maxX) < snapThreshold {
                draggedView.frame.origin.x = otherFrame.maxX - draggedFrame.width
            } else if abs(draggedFrame.midX - otherFrame.midX) < snapThreshold {
                draggedView.center.x = otherFrame.midX
            } else if abs(draggedFrame.minX - otherFrame.maxX) < snapThreshold {
                draggedView.frame.origin.x = otherFrame.maxX
            } else if abs(draggedFrame.maxX - otherFrame.minX) < snapThreshold {
                draggedView.frame.origin.x = otherFrame.minX - draggedFrame.width
            }
            
        }
    }
    
    // Horizontal guide line drawing function
    func drawHorizontalGuideLine(at yPosition: CGFloat) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: yPosition))
        path.addLine(to: CGPoint(x: canvasView.bounds.width, y: yPosition))
        
        let guideLine = CAShapeLayer()
        guideLine.path = path.cgPath
        guideLine.strokeColor = UIColor.orange.cgColor
        guideLine.lineWidth = 1.0
        guideLine.lineDashPattern = [4, 2]
        self.canvasView.layer.addSublayer(guideLine)
        guideLines.append(guideLine)
    }
    
    // Function of drawing vertical guide line
    func drawVerticalGuideLine(at xPosition: CGFloat) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: xPosition, y: 0))
        path.addLine(to: CGPoint(x: xPosition, y: canvasView.bounds.height))
        
        let guideLine = CAShapeLayer()
        guideLine.path = path.cgPath
        guideLine.strokeColor = UIColor.orange.cgColor
        guideLine.lineWidth = 1.0
        guideLine.lineDashPattern = [4, 2]
        self.canvasView.layer.addSublayer(guideLine)
        guideLines.append(guideLine)
    }
    
    // Guide lines update function
    func updateGuideLines(for draggedView: UIImageView) {
        removeGuideLines()
        
        for imageView in imageViews where imageView != draggedView {
            let draggedFrame = draggedView.frame
            let otherFrame = imageView.frame
            
            // Horizontal guide lines
            if draggedFrame.minY == otherFrame.minY {
                drawHorizontalGuideLine(at: draggedFrame.minY)
            }
            if draggedFrame.maxY == otherFrame.maxY {
                drawHorizontalGuideLine(at: draggedFrame.maxY)
            }
            if draggedFrame.midY == otherFrame.midY {
                drawHorizontalGuideLine(at: draggedFrame.midY)
            }
            if draggedFrame.minY == otherFrame.maxY {
                drawHorizontalGuideLine(at: draggedFrame.minY)
            }
            if draggedFrame.maxY == otherFrame.minY {
                drawHorizontalGuideLine(at: draggedFrame.maxY)
            }
            
            // Vertical guide lines
            if draggedFrame.minX == otherFrame.minX {
                drawVerticalGuideLine(at: draggedFrame.minX)
            }
            if draggedFrame.maxX == otherFrame.maxX {
                drawVerticalGuideLine(at: draggedFrame.maxX)
            }
            if draggedFrame.midX == otherFrame.midX {
                drawVerticalGuideLine(at: draggedFrame.midX)
            }
            if draggedFrame.minX == otherFrame.maxX {
                drawVerticalGuideLine(at: draggedFrame.minX)
            }
            if draggedFrame.maxX == otherFrame.minX {
                drawVerticalGuideLine(at: draggedFrame.maxX)
            }
        }
    }
    
    // Remove guide lines function
    func removeGuideLines() {
        for line in guideLines {
            line.removeFromSuperlayer()
        }
        guideLines.removeAll()
    }
}

extension CanvasViewController: ImagePickerDelegate {
    func didSelectImage(_ image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.isUserInteractionEnabled = true
        imageViews.append(imageView)
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
