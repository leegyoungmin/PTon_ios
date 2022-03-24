//
//  extensions.swift
//  PTon
//
//  Created by 이경민 on 2022/02/11.
//

import Foundation
import SwiftUI
import Combine
import Firebase

//Colors
let backgroundColor = Color("Background")
let pink = Color("pink")
let sky = Color("skyblue")
let yello = Color("myyellow")

extension Bundle{
    func decode<T:Codable>(_ file:String)->T{
        //1. Locate json
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in Bundle.")
        }
        //2. Create property
        guard let data = try? Data(contentsOf: url) else{
            fatalError("Failed to Load \(file) from Bundle.")
        }
        //3. Create decoder
        let decoder = JSONDecoder()
        
        //4. deocoded data
        guard let loaded = try? decoder.decode(T.self, from: data) else{
            fatalError("Failed to decode \(file) from Bundle.")
        }
        //5. return data
        return loaded
    }
}

//날짜 차이 구하기
func convertInteval(firstDate:Date,second:Date)->Int{
    let currentCal = Calendar.current
    
    return currentCal.dateComponents([.day], from: second, to: firstDate).day!
}

//String -> Date
func convertdate(content:String,format:String)->Date{
    let formatter = DateFormatter()
    formatter.dateFormat = format
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter.date(from: content)!
}

//Date -> String
func convertString(content:Date,dateFormat:String)->String{
    let formatter = DateFormatter()
    formatter.dateFormat = dateFormat
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter.string(from: content)
}

//프로필 아이콘 모델
struct icon:Hashable{
    var iconName:String
    var iconImageName:String
}
//프로필 아이템 함수
func geticons()->[icon]{
    return [
        icon(iconName: "채팅하기", iconImageName: "message.fill"),
        icon(iconName: "일지확인", iconImageName: "bookmark.fill"),
        icon(iconName: "스트레칭", iconImageName: "figure.walk"),
        icon(iconName: "설문조사", iconImageName: "list.bullet.circle"),
        icon(iconName: "메모하기", iconImageName: "doc.on.doc.fill"),
        icon(iconName: "운동요청", iconImageName: "flag.fill")
    ]
}

//스트레칭 모델
struct Stretching:Codable,Hashable{
    let title:String
    let explain:String
    let videoID:String
}

//설문조사 질문 모델
struct Question:Codable,Hashable{
    let question:String
    let answer1:String
    let answer2:String
}

struct FirebaseHomeImage:View{
    let imageUrl:String
    var body: some View{
        AsyncImage(url: URL(string: imageUrl)) { phase in
            switch phase{
            case .empty:
                VStack{
                    ProgressView()
                        .progressViewStyle(.circular)
                }
                .frame(width: 50, height: 50, alignment: .center)
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50, alignment: .center)
                    .cornerRadius(25)
            case .failure(_):
                Image(systemName: "xmark")
                    .scaledToFit()
                    .frame(width: 50, height: 50, alignment: .center)
            @unknown default:
                VStack{
                    ProgressView()
                        .progressViewStyle(.circular)
                }
                .frame(width: 50, height: 50, alignment: .center)
            }
        }
    }
}

struct ChattingUrlView:View{
    @ObservedObject var urlImageModel:UrlImageModel
    static let defaultImage = ProgressView()
    
    init(urlString:String?){
        urlImageModel = UrlImageModel(urlString: urlString)
    }
    
    var body: some View{
        if urlImageModel.image != nil{
            Image(uiImage: urlImageModel.image!)
                .resizable()
                .scaledToFit()
        }
        else{
            URLImageView.defaultImage
                .progressViewStyle(.circular)
                .scaledToFit()
                .frame(minWidth:200)
        }

    }
    
}

struct FirebaseProfileImage:View{
    let imageUrl:String
    var body: some View{
        AsyncImage(url: URL(string: imageUrl)) { phase in
            switch phase{
            case .empty:
                VStack{
                    ProgressView()
                        .progressViewStyle(.circular)
                }
                .frame(width: 300, height: 300, alignment: .center)
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300, alignment: .center)
                    .cornerRadius(150)
            case .failure(_):
                Image(systemName: "xmark")
                    .scaledToFit()
                    .frame(width: 300, height: 300, alignment: .center)
            @unknown default:
                VStack{
                    ProgressView()
                        .progressViewStyle(.circular)
                }
                .frame(width: 300, height: 300, alignment: .center)
            }
        }
    }
}


struct URLImageView:View{
    @ObservedObject var urlImageModel:UrlImageModel
    let imageSize:CGFloat
    let youtube:Bool
    static let defaultImage = Image("defaultImage")
    init(urlString:String?,imageSize:CGFloat,youtube:Bool){
        urlImageModel = UrlImageModel(urlString: urlString)
        self.imageSize = imageSize
        self.youtube = youtube
    }
    
    var body: some View{
        if urlImageModel.image != nil{
            if youtube{
                Image(uiImage: urlImageModel.image!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 60, alignment: .center)
            }else{
                Image(uiImage: urlImageModel.image!)
                    .resizable()
                    .frame(width: imageSize, height: imageSize, alignment: .center)
                    .clipShape(
                        Circle()
                    )
                    .background(
                        Circle()
                            .stroke(.gray)
                    )
            }
        }
        else{
            URLImageView.defaultImage
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize, alignment: .center)
                .clipShape(Circle())
                .background(
                    Circle()
                        .stroke(.gray)
                )
        }

    }
    

}

class UrlImageModel:ObservableObject{
    @Published var image:UIImage?
    var imageCache = ImageChache.getImageCache()
    
    var urlString:String?
    
    init(urlString:String?){
        self.urlString = urlString
        loadImage()
    }
    
    func loadImage(){
        
        if loadImageFromCache(){
            return
        }
        
        loadImageFromUrl()
    }
    
    func loadImageFromUrl(){
        guard let urlString = urlString else {
            return
        }
        
        if urlString != ""{
            let url = URL(string: urlString)!
            let task = URLSession.shared.dataTask(with: url, completionHandler: getImageFromResponse(data:response:error:))
            task.resume()
        }
    }
    
    func loadImageFromCache()->Bool{
        guard let urlString = urlString else {
            return false
        }
        
        guard let cacheImage = imageCache.get(forkey: urlString) else{
            return false
        }
        
        image = cacheImage
        return true

    }
    
    func getImageFromResponse(data:Data?,response:URLResponse?,error:Error?){
        guard error == nil else{return}
        
        guard let data = data else{
            return
        }
        
        DispatchQueue.main.async {
            guard let loadedImage = UIImage(data: data) else{return}
            
            self.imageCache.set(forkey: self.urlString!, image: loadedImage)
            self.image = loadedImage
        }
    }
    
}

class ImageChache{
    var cache = NSCache<NSString,UIImage>()
    
    func get(forkey:String) -> UIImage?{
        return cache.object(forKey: NSString(string: forkey))
    }
    
    func set(forkey:String,image:UIImage){
        cache.setObject(image, forKey: NSString(string: forkey))
    }
}

extension ImageChache{
    private static var imageCache = ImageChache()
    
    static func getImageCache()->ImageChache{
        return imageCache
    }
}

extension String{
    var bool:Bool{
        if self.lowercased() == "false"{
            return false
        }else if self.lowercased() == "true"{
            return true
        }else{
            return false
        }
    }
}

extension View{
    func placeholder<Content:View>(
        when shouldShow:Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: ()->Content
    ) -> some View{
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1:0)
            self
        }
    }
}
