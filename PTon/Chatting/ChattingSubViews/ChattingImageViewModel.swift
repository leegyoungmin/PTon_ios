//
//  ChattingImageViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/03/11.
//

import Foundation
import Firebase

class ChattingImageViewModel:ObservableObject{
    var path:String
    init(path:String){
        self.path = path
        
        print(path)
    }
    
    func fetchImage(completion:@escaping(UIImage)->Void){
        FirebaseStorage.Storage.storage().reference()
            .child("ChatsImage")
            .child(path)
            .getData(maxSize: 15 * 1024 * 1024) { data, error in
                if error != nil{
                    print("error : \(error.debugDescription)")
                    return
                } else {
                    if let image = UIImage(data: data!){
                        completion(image)
                    }else{
                        print("error : Can't convert Image")
                        return
                    }
                }
            }
    }
}
