//
//  ChattingImageViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/03/11.
//

import Foundation
import Firebase
import SDWebImageSwiftUI

class ChattingImageViewModel:ObservableObject{
    @Published var imageURL:URL?
    var path:String
    init(path:String){
        self.path = path
        
        fetchImage()
    }
    
    func fetchImage(){
        FirebaseStorage.Storage.storage().reference()
            .child("ChatsImage")
            .child(path)
            .downloadURL(completion: { url, error in
                if error == nil{
                    self.imageURL = url
                }
            })
    }
}
