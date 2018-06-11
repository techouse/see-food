//
//  ViewController.swift
//  SeeFood
//
//  Created by Klemen Tušar on 11.06.2018.
//  Copyright © 2018 Klemen Tušar. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera // probably the simplest way of incorporating a camera into any app :)
        // imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }
    
    // delegate method of UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // get a hold of the image that the user has picked and downcast it to an UIImage
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIImage!")
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        // VNCoreMLModel comes from the Vision model
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML model failed!")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            // process the results of the request
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image!")
            }
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                } else {
                    self.navigationItem.title = "Not Hotdog!"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print("There was an error performing the detection request, \(error)")
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}

