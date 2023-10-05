//
//  ViewController.swift
//  ImageRecognition
//
//  Created by Çağan Bıçakçı on 27.09.2023.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    var chosenImage : CIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func changeImageButtonClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
        
        if let CIImage = CIImage(image: imageView.image!) {
            self.chosenImage = CIImage
        }
        
        recognizeImage(image: chosenImage!)
    }
    
    func recognizeImage(image: CIImage){
        
        let defaultConfig = MLModelConfiguration()
        
        if let model = try? VNCoreMLModel(for: MobileNetV2(configuration: defaultConfig).model) {
            let request = VNCoreMLRequest(model: model) { vnrequest, error in
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    if results.count > 0 {
                        let topResult = results.first
                        DispatchQueue.main.async{
                            let confidenceLevel = (topResult?.confidence ?? 0) * 100
                            let roundedConfidenceLevel = Int(confidenceLevel)
                            self.resultLabel.text = "It is \(roundedConfidenceLevel)% \(topResult!.identifier)"
                        }
                    }
                }
            }
            
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do{
                    try handler.perform([request])
                } catch {
                    print("Error")
                }

            }
            
        }
    }
}
