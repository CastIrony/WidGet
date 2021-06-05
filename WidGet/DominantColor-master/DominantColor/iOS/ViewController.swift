//
//  ViewController.swift
//  Dominant Color iOS
//
//  Created by Jamal E. Kharrat on 12/22/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

import DominantColor
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var boxes: [UIView]!
    @IBOutlet var imageView: UIImageView!

    var image: UIImage!

    // MARK: IBActions

    @IBAction func selectImage(_: AnyObject) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary

        present(imagePickerController, animated: true, completion: nil)
    }

    @IBAction func runBenchmarkTapped(_: AnyObject) {
        if let image = image {
            let nValues: [Int] = [100, 1000, 2000, 5000, 10000]
            let CGImage = image.cgImage
            for n in nValues {
                let ns = dispatch_benchmark(5) {
                    _ = dominantColorsInImage(CGImage!, maxSampledPixels: n)
                }
                print("n = \(n) averaged \(ns / 1_000_000) ms")
            }
        }
    }

    // MARK: ImagePicker Delegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image: UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage? {
            self.image = image
            imageView.image = image

            let colors = image.dominantColors()
            for box in boxes {
                box.backgroundColor = UIColor.clear
            }
            for i in 0 ..< min(colors.count, boxes.count) {
                boxes[i].backgroundColor = colors[i]
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (key.rawValue, value) })
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
