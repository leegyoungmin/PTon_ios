//
//  MealEditViews.swift
//  PTon
//
//  Created by 이경민 on 2022/03/24.
//

import Foundation
import SwiftUI

enum ImageType{
    case upload,update
}

struct MealEditViews:View{
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel:MealRecordViewModel
    @Binding var ispresented:Bool
    @Binding var image:UIImage
    @Binding var uuid:String
    let imageType:ImageType
    let selectedDate:Date
    let index:Int
    let mealTypes = mealType.allCases.map({$0.rawValue})
    @State var isPresentSearch:Bool = false
    @State private var offsetY: CGFloat = CGFloat.zero
    @State var typingText:String = "음식검색"
    @State var memoText = ""
    @State var isProgrss:Bool = false
    
    let countries = Array(repeating: "Example \(UUID().uuidString)", count: 20)
    
    var body: some View{
        ZStack{
            VStack(alignment:.center){
                
                Image(uiImage: image)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width:UIScreen.main.bounds.width*0.9,height:UIScreen.main.bounds.width*0.9)
                    .cornerRadius(15)
                    .clipped()
                    .padding(.top)

                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    ForEach(searchResult,id:\.self){ food in
                        Button {
                            UIApplication.shared.endEditing()
                            isProgrss = true
                            
//                            viewModel.setImageData(selectedDate, index: index, image: image, foodName: food, ImageType: imageType, uuid: uuid) {
//                                self.isProgrss = false
//                                self.ispresented = false
//                            }
                        } label: {
                            HStack{
                                Text(food)
                                Spacer()
                                
                            }
                        }
                        .padding()

                    }
                    
                }
                
                Spacer()
            }
            .disabled(isProgrss)
            
            if isProgrss{
                ProgressView()
                    .progressViewStyle(.circular)
            }
            
        }
        .background(backgroundColor)
//        .navigationTitle(mealTypes[index])
        .searchable(text: $typingText)
    }
    var searchResult:[String]{
        if typingText.isEmpty{
            return countries
        }
        else{
            return countries.filter{$0.contains(typingText)}
        }
    }
}

struct Header:View{
    @State private var userText = ""
    var body: some View{
        TextField("음식이름을 검색하세요.", text: $userText)
            .padding()
            .frame(minWidth:0,maxWidth: .infinity)
            .background(Rectangle().foregroundColor(.white))
        
    }
}

