//
//  ChattingImagePickerView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/09.
//

import Foundation
import SwiftUI
import Firebase
import PhotosUI

struct ChattingImagePickerView:UIViewControllerRepresentable{
    @EnvironmentObject var viewmodel:ChattingViewModel
    @Binding var isPresented:Bool
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration:PHPickerConfiguration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 0
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
        private let parent:ChattingImagePickerView
        
        init(_ parent:ChattingImagePickerView){
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            
            
            let itemProvider = results.first?.itemProvider
            
            if let itemProvider = itemProvider,
               itemProvider.canLoadObject(ofClass: UIImage.self){
                itemProvider.loadObject(ofClass: UIImage.self) { (image,error) in
                    guard let image = image as? UIImage,
                          let data = image.jpegData(compressionQuality: 0.8) else{return}
                    
                    DispatchQueue.main.async {
                        self.parent.viewmodel.imageAppend(image: data)
                        
                        self.parent.viewmodel.uploadImage(data) { path in
                            self.parent.viewmodel.sendImage(path: path)
                        }
                    }
                    
                }
            }
            
            parent.isPresented = false
        }
    }
}

struct ChattingCameraView:UIViewControllerRepresentable{
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewmodel:ChattingViewModel
    let sourceType : UIImagePickerController.SourceType = .camera
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ChattingCameraView>) -> UIImagePickerController {
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
        
        var parent:ChattingCameraView
        
        init(_ parent:ChattingCameraView){
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
               let data = image.jpegData(compressionQuality: 0.8){
                
                DispatchQueue.main.async {
                    self.parent.viewmodel.imageAppend(image: data)
                    
                    self.parent.viewmodel.uploadImage(data) { path in
                        self.parent.viewmodel.sendImage(path: path)
                    }
                }
            }
            parent.dismiss.callAsFunction()
        }
    }
}
