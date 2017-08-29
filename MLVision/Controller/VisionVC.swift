//
//  VisionVC.swift
//  MLVision
//
//  Created by Vitaliy Maksymlyuk on 8/25/17.
//  Copyright © 2017 Vitaliy Maksymlyuk. All rights reserved.
//

import UIKit
import AVFoundation

class VisionVC: UIViewController {
    
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photoData: Data?
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var roundedLblView: RoundedShadowView!
    @IBOutlet weak var identLbl: UILabel!
    @IBOutlet weak var confidenceLbl: UILabel!
    @IBOutlet weak var captureImageView: RoundedShadowImageView!
    @IBOutlet weak var flashBtn: RoundedShadowButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = cameraView.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        
        // Adding tap gesture recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCameraView))
        tap.numberOfTapsRequired = 1
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera!)
            if captureSession.canAddInput(input) == true {
                captureSession.addInput(input)
            }
            cameraOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddOutput(cameraOutput) == true {
                captureSession.addOutput(cameraOutput!)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                
                cameraView.layer.addSublayer(previewLayer)
                cameraView.addGestureRecognizer(tap)
                captureSession.startRunning()
            }
        } catch {
            debugPrint(error)
        }
    }
    
    @objc func didTapCameraView() {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let preiewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType, kCVPixelBufferWidthKey as String: 160, kCVPixelBufferHeightKey as String: 160]
        
        settings.previewPhotoFormat = preiewFormat
        
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
}

extension VisionVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let err = error {
            debugPrint(err)
        } else {
            photoData = photo.fileDataRepresentation()
            
            let image = UIImage(data: photoData!)
            self.captureImageView.image = image
        }
    }
}










