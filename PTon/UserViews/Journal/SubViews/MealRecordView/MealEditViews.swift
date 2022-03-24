//
//  MealEditViews.swift
//  PTon
//
//  Created by 이경민 on 2022/03/24.
//

import Foundation
import SwiftUI

struct MealEditViews:View{
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel:MealRecordViewModel
    @Binding var image:UIImage
    let selectedDate:Date
    let index:Int
    let mealTypes = mealType.allCases.map({$0.rawValue})
    @State var typingText = ""
    @State var memoText = ""
    var body: some View{
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
        .background(backgroundColor)
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .navigationTitle(mealTypes[index])
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.setImageData(selectedDate, index: index, image: image, foodName: typingText)
                    dismiss.callAsFunction()

                } label: {
                    Text("저장하기")
                }

            }
        }
    }
}

struct MealEditView_Previews:PreviewProvider{
    static var previews: some View{
        MealEditViews(image: .constant(UIImage(named: "defaultImage")!), selectedDate: Date(), index: 0)
    }
}
