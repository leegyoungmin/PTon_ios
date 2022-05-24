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
import Kingfisher

//Images
let logoImage = Image("defaultImage")

struct CircleImage:View{
    let url:String
    let size:CGSize
    
    var body: some View{
        KFImage(URL(string: url))
            .placeholder({
                logoImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.width, height: size.height, alignment: .center)
            })
            .resizable()
            .frame(width: size.width, height: size.height, alignment: .center)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .strokeBorder(Color.accentColor,lineWidth: 1.5)
            )
    }
}

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
    return formatter.date(from: content) ?? Date()
}

//Date -> String
func convertString(content:Date,dateFormat:String)->String{
    let formatter = DateFormatter()
    formatter.dateFormat = dateFormat
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter.string(from: content)
}

func kcalString(content:Double)->String{
    return String(format: "%.1f", content)
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

extension Bool{
    init<T:BinaryInteger>(_ integer:T){
        if integer == 0{
            self.init(false)
        }else if integer == 1{
            self.init(true)
        }else{
            self.init(false)
        }
    }
}

extension mealType{
    init?(key:String) {
        switch key{
        case "breakfirst":
            self.init(rawValue: 0)
        case "launch":
            self.init(rawValue: 1)
        case "snack":
            self.init(rawValue: 2)
        case "dinner":
            self.init(rawValue: 3)
        default:
            return nil
        }
    }
}

//MARK: - PREVIEWS
struct Extensions_previews:PreviewProvider{
    static var previews: some View{
        CircleImage(url: "https://flif.info/example-images/fish.png", size: CGSize(width: 100, height: 100))
            .previewLayout(.sizeThatFits)
    }
}
