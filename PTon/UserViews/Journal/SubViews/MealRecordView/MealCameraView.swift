//
//  MealImagePickerView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/24.
//

import Foundation
import SwiftUI
import PhotosUI

//MARK: - Meal Image Picker View
struct MealImagePickerView:UIViewControllerRepresentable{
    @Binding var image:UIImage
    @Binding var isPresented:Bool
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration:PHPickerConfiguration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 1
        configuration.filter = .any(of: [.images])
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator{
        Coordinator(self)
    }
    
    
    class Coordinator:PHPickerViewControllerDelegate{
        private let parent:MealImagePickerView
        
        init(_ parent:MealImagePickerView){
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            
            let itemProvider = results.first?.itemProvider
            
            if let itemProvider = itemProvider,
               itemProvider.canLoadObject(ofClass: UIImage.self){
                itemProvider.loadObject(ofClass: UIImage.self) { (image,error) in
                    guard let image = image as? UIImage,
                          let data = image.jpegData(compressionQuality: 0.8) else{return}
                    self.parent.image = image
                    
                }
            }
            
            parent.isPresented = false
        }
    }
}
//MARK: - Meal Camera View
struct MealCameraView:UIViewControllerRepresentable{
    @Environment(\.dismiss) var dismiss
    @Binding var image:UIImage
    let sourceType : UIImagePickerController.SourceType
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MealCameraView>) -> UIImagePickerController {
        let imagepicker = UIImagePickerController()
        imagepicker.allowsEditing = false
        imagepicker.sourceType = sourceType
        imagepicker.delegate = context.coordinator
        return imagepicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator:NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
        
        var parent:MealCameraView
        
        init(_ parent:MealCameraView){
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
               let data = image.jpegData(compressionQuality: 0.8){
                self.parent.image = image
                print(data.debugDescription)
            }
            parent.dismiss.callAsFunction()

        }
    }
}
