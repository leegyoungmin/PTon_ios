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
    @State var typingText:String
    @State var memoText = ""
    @State var isProgrss:Bool = false
    var body: some View{
        ZStack{
            VStack(alignment:.center){
                Image(uiImage: image)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width:UIScreen.main.bounds.width*0.7,height:UIScreen.main.bounds.width*0.7)
                    .cornerRadius(15)
                    .clipped()
                    .padding(.top)
                    
                TextField("", text: $typingText)
                    .placeholder(when: typingText.isEmpty, placeholder: {
                        Text("음식이름").foregroundColor(.gray)
                    })
                    .font(.system(.largeTitle, design: .rounded))
                    .padding()
                
                Text("메모 작성")
                    .font(.title)
                    .padding(.horizontal)
                    .frame(alignment: .leading)
                
                TextEditor(text: $memoText)
                    .background(.white)
                    .cornerRadius(20)
                    .padding(.horizontal)
            }
            .disabled(isProgrss)
            
            if isProgrss{
                ProgressView()
                    .progressViewStyle(.circular)
            }
            
        }
        .background(backgroundColor)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .navigationTitle(mealTypes[index])
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        UIApplication.shared.endEditing()
                        isProgrss = true
                        
                        viewModel.setImageData(selectedDate, index: index, image: image, foodName: typingText, ImageType: imageType, uuid: uuid) {
                            self.isProgrss = false
                            self.ispresented = false
                        }
                    } label: {
                        Text(imageType == .update ? "수정하기":"저장하기")
                    }

                }
            }
    }
}

//struct MealEditView_Previews:PreviewProvider{
//    static var previews: some View{
//        MealEditViews(image: .constant(UIImage(named: "defaultImage")!), selectedDate: Date(), index: 0)
//    }
//}
