//
//  PhotoPickerView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/19.
//

import SwiftUI
import Firebase

struct ImagePickerView:UIViewControllerRepresentable{
    @Environment(\.dismiss) private var dismiss
    var sourceType:UIImagePickerController.SourceType = .photoLibrary
    @Binding var isChanged:Bool
    @EnvironmentObject var viewmodel:UserBaseViewModel
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagepicker = UIImagePickerController()
        imagepicker.allowsEditing = true
        imagepicker.sourceType = sourceType
        imagepicker.delegate = context.coordinator
        return imagepicker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator:NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
        
        var parent:ImagePickerView
        
        init(_ parent:ImagePickerView){
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                self.parent.isChanged = true
                parent.viewmodel.uploadImage(image: image) { isSuccess in
                    withAnimation {
                        if isSuccess{

                            self.parent.isChanged = false
                        }else{
                            self.parent.isChanged = false
                        }
                    }

                }
                
                self.parent.dismiss.callAsFunction()
            }
            
        }
    }
}

