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

//MARK: - Chatting Image Picker View
struct ChattingImagePickerView:UIViewControllerRepresentable{
    @EnvironmentObject var viewmodel:chattingViewModel
    @Binding var isPhotoType:photoType?
    let userName:String
//    @Binding var isSend:Bool
//    @Binding var isPresented:Bool
    
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
        private let parent:ChattingImagePickerView
        
        init(_ parent:ChattingImagePickerView){
            self.parent = parent
        }
        
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            let itemProvider = results.first?.itemProvider
            
            if let itemProvider = itemProvider,
               itemProvider.canLoadObject(ofClass: UIImage.self){
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    guard let image = image as? UIImage,
                          let imageData = image.jpegData(compressionQuality: 0.5) else {
                        return
                    }
                    self.parent.isPhotoType = nil
                    self.parent.viewmodel.uploadImage(self.parent.userName, imageData: imageData) {
                        print("error ")
                    }
                    
                }
            }else{
                self.parent.isPhotoType = nil
            }
        }
        
    }
}

//MARK: - Chatting Camera View
struct ChattingCameraView:UIViewControllerRepresentable{
    @EnvironmentObject var viewmodel:chattingViewModel
    @Binding var isPhotoType:photoType?
    let userName:String
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
               let data = image.jpegData(compressionQuality: 0.5){
                self.parent.isPhotoType = nil
                self.parent.viewmodel.uploadImage(self.parent.userName, imageData: data) {
                    print("Error in image")
                }
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.isPhotoType = nil
        }
    }
}


//MARK: - USER
struct UserChattingImagePickerView:UIViewControllerRepresentable{
    @EnvironmentObject var viewmodel:UserChattingViewModel
    @Binding var isPhotoType:photoType?
    
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
        private let parent:UserChattingImagePickerView
        
        init(_ parent:UserChattingImagePickerView){
            self.parent = parent
        }
        
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            let itemProvider = results.first?.itemProvider
            
            if let itemProvider = itemProvider,
               itemProvider.canLoadObject(ofClass: UIImage.self){
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    guard let image = image as? UIImage,
                          let imageData = image.jpegData(compressionQuality: 0.5) else {
                        return
                    }
                    self.parent.isPhotoType = nil
                    self.parent.viewmodel.uploadImage(imageData)
                    
                }
            }else{
                self.parent.isPhotoType = nil
            }
        }
        
    }
}

struct UserChattingCameraView:UIViewControllerRepresentable{
    @EnvironmentObject var viewmodel:UserChattingViewModel
    @Binding var isPhotoType:photoType?
    let sourceType : UIImagePickerController.SourceType = .camera
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<UserChattingCameraView>) -> UIImagePickerController {
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
        
        var parent:UserChattingCameraView
        
        init(_ parent:UserChattingCameraView){
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
               let data = image.jpegData(compressionQuality: 0.5){
                self.parent.isPhotoType = nil
                self.parent.viewmodel.uploadImage(data)
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.isPhotoType = nil
        }
    }
}
