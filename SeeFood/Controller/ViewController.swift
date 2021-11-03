//
//  ViewController.swift
//  SeeFood
//
//  Created by Piotr Szerszeń on 22/10/2021.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!

    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        // replace with .camera for testing on phisical device
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false

    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }

}

// MARK: - UIImagePickerControllerDelegate

extension ViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let userPickedImage = info[.originalImage] as? UIImage {
            imageView.image = userPickedImage
            imagePicker.dismiss(animated: true, completion: nil)
            guard let ciImage = CIImage(image: userPickedImage) else { fatalError("couldn't convert uiimage to CIImage") }
            detect(ciImage)
        }
    }

    private func detect(_ image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3(configuration: MLModelConfiguration()).model) else {
            fatalError("Loading coreML model failed")
        }

        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                    let topResult = results.first else {
                        fatalError("error getting results")
                    }
            let hotdog = topResult.identifier.contains("hotdog")
            DispatchQueue.main.async {
                self.navigationItem.title = hotdog ? "Hotdog!" : "Not Hotdog!"
                self.navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = hotdog ? .green : .red
                self.navigationController?.navigationBar.isTranslucent = false
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)

        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
}
