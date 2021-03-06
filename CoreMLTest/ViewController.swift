//
//  ViewController.swift
//  CoreMLTest
//
//  Created by 平井瑛 on 2019/01/02.
//  Copyright © 2019 Ei Hirai. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var imagePicker = UIImagePickerController()
    let resnetModel = Resnet50()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
    }
    
    func processImage(image: UIImage) {
        if let model = try? VNCoreMLModel(for: self.resnetModel.model) {
            let request = VNCoreMLRequest(model: model) { (request, error) in
                if let results = request.results as? [VNClassificationObservation] {
                    for classification in results {
                        print("ID: \(classification.identifier) Confidence: \(classification.confidence)")
                    }
                    self.descriptionLabel.text = results.first?.identifier
                    if let confidence = results.first?.confidence {
                        self.confidenceLabel.text = "\(confidence * 100.0)%"
                    }
                }
            }
            if let imageData = image.pngData() {
                let handler = VNImageRequestHandler(data: imageData, options: [:])
                try? handler.perform([request])
            }
        }
    }

    @IBAction func photosTapped(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = selectedImage
            processImage(image: selectedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func trashTapped(_ sender: Any) {
        imageView.image = nil
        descriptionLabel.text = "category"
        confidenceLabel.text = "confidence"
    }
    
}

