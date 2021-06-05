//
//  ImagePicker.swift
//
//
//  Created by Bernstein, Joel on 7/10/20.
//

import PhotosUI
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    let configuration: PHPickerConfiguration

    @Binding var uiImage: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> PHPickerViewController {
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_: PHPickerViewController, context _: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: PHPickerViewControllerDelegate {
        private let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self)
            {
                itemProvider.loadObject(ofClass: UIImage.self) {
                    image, error in

                    if let uiImage = image as? UIImage {
                        self.parent.uiImage = uiImage.fixedOrientation()?.thumbnail(maxThumbnailSize: CGSize(width: 800, height: 800))
                    } else {
                        print("Could not load image", error?.localizedDescription ?? "")
                    }

                    self.parent.presentationMode.wrappedValue.dismiss()
                }
            } else {
                parent.presentationMode.wrappedValue.dismiss()
            }
        }
    }

//    @Binding var pickedImageURL: URL?
//
//    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate
//    {
//        let parent: ImagePicker
//
//        init(_ parent: ImagePicker)
//        {
//            self.parent = parent
//        }
//
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
//        {
//            if let pickedImageURL = info[.imageURL] as? URL
//            {
//                parent.pickedImageURL = pickedImageURL
//            }
//
//            parent.presentationMode.wrappedValue.dismiss()
//        }
//    }
//
//    @Environment(\.presentationMode) var presentationMode
//
//    func makeCoordinator() -> Coordinator
//    {
//        Coordinator(self)
//    }
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController
//    {
//        let picker = UIImagePickerController()
//
//        picker.delegate = context.coordinator
//        picker.allowsEditing = false
//
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>)
//    {
//
//    }
}
