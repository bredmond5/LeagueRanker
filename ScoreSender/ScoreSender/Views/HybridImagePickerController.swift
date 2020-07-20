//
//  HybridImagePicker.swift
//  ScoreSender
//
//  Created by Brice Redmond on 5/11/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI

struct HybridImagePickerController: UIViewControllerRepresentable {
    var didAddImage: (UIImage) -> ()
    
    @Binding var isPresented: Bool

    func makeUIViewController(context: UIViewControllerRepresentableContext<HybridImagePickerController>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func makeCoordinator() -> HybridImagePickerController.Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        var parent: HybridImagePickerController

        init(_ parent: HybridImagePickerController) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let selectedImage = info[.originalImage] as! UIImage
            parent.didAddImage(selectedImage)
            parent.isPresented = false
            picker.dismiss(animated: true)
        }

    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<HybridImagePickerController>) {

    }

}
