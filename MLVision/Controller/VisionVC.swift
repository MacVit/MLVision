//
//  VisionVC.swift
//  MLVision
//
//  Created by Vitaliy Maksymlyuk on 8/25/17.
//  Copyright © 2017 Vitaliy Maksymlyuk. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

enum FlashState {
    case on
    case off
}

class VisionVC: UIViewController {
    
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photoData: Data?
    
    var flashControllState: FlashState = .off
    
    var speechSynthesizer = AVSpeechSynthesizer()
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var roundedLblView: RoundedShadowView!
    @IBOutlet weak var identLbl: UILabel!
    @IBOutlet weak var confidenceLbl: UILabel!
    @IBOutlet weak var captureImageView: RoundedShadowImageView!
    @IBOutlet weak var flashBtn: RoundedShadowButton!
    @IBOutlet weak var spinnerProgress: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = cameraView.bounds
        speechSynthesizer.delegate = self
        spinnerProgress.isHidden = true
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
        
        self.cameraView.isUserInteractionEnabled = false
        self.spinnerProgress.isHidden = false
        self.spinnerProgress.startAnimating()
        
        let settings = AVCapturePhotoSettings()
        
        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat
        
        if flashControllState == .off {
            settings.flashMode = .off
        } else {
            settings.flashMode = .on
        }
        
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoPredictResult(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation] else { return }
        
        for classification in results {
            print(classification.identifier)
            if classification.confidence < 0.5 {
                let unknowObjectMessage = "No object detected. Please try again"
                self.identLbl.text = unknowObjectMessage
                synthesizeSpeech(fromString: unknowObjectMessage)
                self.confidenceLbl.text = ""
                break
            
            } else {
                let identObjMessage = classification.identifier
                let confidenceMessage = Int(classification.confidence * 100)
                self.identLbl.text = identObjMessage
                self.confidenceLbl.text = "Current CONFIDENCE:\(confidenceMessage)%"
                let completedMessage = "This looks like a \(identObjMessage) and I'm \(confidenceMessage) percent sure"
                synthesizeSpeech(fromString: completedMessage)
                break
            }
        }
    }
    
    func synthesizeSpeech(fromString string: String) {
        let speechUtterance = AVSpeechUtterance(string: string)
        speechSynthesizer.speak(speechUtterance)
    }
    
    @IBAction func flashBtnWasPressed(_ sender: Any) {
        
        switch flashControllState {
        case .off:
            flashBtn.setTitle("FLASH ON", for: .normal)
            flashControllState = .on
        case .on:
            flashBtn.setTitle("FLASH OFF", for: .normal)
            flashControllState = .off
        }
    }
}

extension VisionVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let err = error {
            debugPrint(err)
        } else {
            photoData = photo.fileDataRepresentation()
            
            // Trying pass the existing photoData intro Core ML -> SQueezwNet model
            
            do {
                let model = try VNCoreMLModel(for: SqueezeNet().model)
                let request = VNCoreMLRequest(model: model, completionHandler: photoPredictResult)
                let handler = VNImageRequestHandler(data: photoData!)
                try handler.perform([request])
            } catch {
                debugPrint("Woops we have some error(s) with the photo processing:\(error.localizedDescription)")
            }
            
            let image = UIImage(data: photoData!)
            self.captureImageView.image = image
        }
    }
}

extension VisionVC: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.cameraView.isUserInteractionEnabled = true
        self.spinnerProgress.isHidden = true
        self.spinnerProgress.stopAnimating()
    }
}








