//
//  CameraController.swift
//  Instagram Clone
//
//  Created by morua on 1/11/21.
//  Copyright © 2021 morua. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate, UIViewControllerTransitioningDelegate {
    
    // MARK: - Properties
    let dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "right_arrow_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()

    let capturePhotoButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "capture_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleTakePhoto), for: .touchUpInside)
        return button
    }()
    
    let photoOutput = AVCapturePhotoOutput()
    let customAnimationPresentor = CustomAnimationPresentor()
    let customAnimationDismisser = CustomAnimationDismisser()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitioningDelegate = self
        
        openCamera()
    }
    
    // MARK: - Fileprivate functions
    fileprivate func openCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // the user has already authorized to access the camera
            self.setupCaptureSession()
        case .notDetermined: // the user has not yet asked for camera access
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted { // if user has granted to access the camera
                    print("the user has granted to access the camera")
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                    }
                } else {
                    print("the user has not granted to access the camera")
                    self.handleDismiss()
                }
            }
        case .denied:
            print("the user has denied previously to access the camera")
            self.handleDismiss()
        case .restricted:
            print("the user can't give camera access due to some restriction")
            self.handleDismiss()
        default:
            print("something has wrong due to we can't access the camera")
            self.handleDismiss()
        }
    }
    
    fileprivate func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        
        if let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) {
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            } catch let error {
                print("Failed to set input device with error: \(error)")
            }
            
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            let cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            cameraLayer.frame = view.frame
            cameraLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(cameraLayer)
            
            captureSession.startRunning()
            
            setupHUD()
        }
    }
    
    fileprivate func setupHUD() {
        view.addSubview(capturePhotoButton)
        view.addSubview(dismissButton)

        capturePhotoButton.centerXInSuperview()
        capturePhotoButton.anchor(top: nil, leading: nil, bottom: view.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 40, right: 0), size: .init(width: 80, height: 80))

        dismissButton.anchor(top: view.topAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 12, left: 0, bottom: 0, right: 12), size: .init(width: 50, height: 50))
    }
    
    // MARK: - Action functions
    @objc func handleTakePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationPresentor
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationDismisser
    }
    
    // MARK: - AVCapturePhotoCaptureDelegate
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let previewImage = UIImage(data: imageData)
        
        let containerView = PreviewPhotoContainerView()
        containerView.previewImageView.image = previewImage
        view.addSubview(containerView)
        containerView.fillSuperview()
    }
}
