//
//  EditModeMemoView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/23.
//

import Foundation
import SwiftUI

struct EditModeMemoView:View{
    //MARK: - PROPERTIES
    @Binding var currentMemo:Memo
    var body: some View{
        //MARK: - VIEW
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment:.leading,spacing:5){
                Text(currentMemo.time.replacingOccurrences(of: "-", with: "."))
                    .font(.callout)
                    .foregroundColor(.gray.opacity(0.5))
                
                TextEditor(text: $currentMemo.content)
                    .font(.title3)
                    .multilineTextAlignment(.leading)
                    .frame(minHeight:200,alignment: .top)
                
                Text("식단")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.vertical)
                
                mealEditCell(mealType: "아침", meals: $currentMemo.firstMeal)
                    .padding(.bottom)
                
                mealEditCell(mealType: "점심",meals: $currentMemo.secondMeal)
                    .padding(.bottom)
                
                mealEditCell(mealType: "간식",meals: $currentMemo.snack)
                    .padding(.bottom)
                
                mealEditCell(mealType: "저녁", meals: $currentMemo.thirdMeal)
                    .padding(.bottom)
                
            }.padding(.horizontal)
        }
        .navigationTitle(currentMemo.title)
        .navigationBarTitleDisplayMode(.large)
        .onTapGesture {
            withAnimation {
                UIApplication.shared.endEditing()
            }
        }
    }
}

//MARK: - 식사 수정 셀 뷰
struct mealEditCell:View{
    let mealType:String
    @Binding var meals:[String]
    var body: some View{
        VStack(alignment: .leading,spacing:10){
            Text(mealType)
                .font(.title2)
                .fontWeight(.semibold)
            
            ForEach(meals.indices,id: \.self) { index in
                HStack{
                    TextField("", text: $meals[index])
                        .foregroundColor(.accentColor)
                    
                    Spacer()
                    
                    Button {
                        meals.remove(at: index)
                    } label: {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                    .tint(Color.accentColor)
                }
                .padding(10)
                .background(Color("Background"))
                .cornerRadius(10)
            }
            
            Button {
                meals.append("")
            } label: {
                HStack{
                    Spacer()
                    
                    Label {
                        Text("추가하기")
                    } icon: {
                        Image(systemName: "plus")
                    }
                    .foregroundColor(.accentColor)
                    
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            .padding(10)
            .background(Color("Background"))
            .cornerRadius(10)

        }
        .padding(.horizontal)
    }
}
