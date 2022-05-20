//
//  MemoCreateView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/12.
//

import SwiftUI
import AlertToast

enum mealType:Int,CaseIterable{
    case first = 0
    case second
    case snack
    case third
    
    func description()->String{
        switch self {
        case .first:
            return "아침"
        case .second:
            return "점심"
        case .snack:
            return "간식"
        case .third:
            return "저녁"
        }
    }
}

struct MemoCreateView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewmodel : MemoCreateViewModel
    @State var isPrivate : Bool = false
    @State var title:String = ""
    @State var content:String = "내용을 입력해주세요."
    @State var selectedIndex = 1
    
    @State var firstMealCount:Int = 0
    @State var secondMealCount:Int = 0
    @State var thirdMealCount:Int = 0
    
    init(viewmodel:MemoCreateViewModel){
        _viewmodel = StateObject.init(wrappedValue: viewmodel)
        UITextView.appearance().backgroundColor = .clear
    }
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading){
                
                TextField("제목을 입력하세요.", text: $title)
                    .font(.title)
                    .padding(.vertical)
                
                
                Toggle(isOn: $isPrivate) {
                    Text("비공개 설정")
                }
                .padding()
                .background(
                    backgroundColor
                )
                .cornerRadius(15)
                
                TextEditor(text: $content)
                    .foregroundColor(content == "내용을 입력해주세요." ? .gray:.black)
                    .padding()
                    .background(backgroundColor)
                    .frame(minHeight:250,maxHeight:300)
                    .cornerRadius(15)
                    .onTapGesture {
                        if content == "내용을 입력해주세요."{
                            content = ""
                        }
                    }
                
                Text("식단")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.vertical)
                
                Group{
                    mealCellView(title: "아침",index: 0)
                       
                    mealCellView(title: "점심",index: 1)
                    
                    mealCellView(title: "간식",index: 2)
                    
                    mealCellView(title: "저녁",index: 3)
                }
                .padding(.horizontal,10)
                .environmentObject(self.viewmodel)
                

            }
        }
        .padding(.horizontal)
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("저장하기")
                    .onTapGesture {
                        let data = memo(isprivate: isPrivate, title: title, content: content, meal: viewmodel.meals)
                        
                        DispatchQueue.main.async {
                            dismiss.callAsFunction()
                            viewmodel.updateData(data: data)
                        }
                        

                    }
            }
        }
        .onDisappear {
            viewmodel.disAppear()
        }
    }
}

struct mealCellView:View{
    @EnvironmentObject var viewmodel:MemoCreateViewModel
    let title:String
    let index:Int
    var body: some View{
        
        VStack(alignment: .leading, spacing: 10){
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            ForEach(viewmodel.meals[index].foodList.indices,id:\.self) { mealIndex in
                
                HStack{
                    TextField("음식을 작성해주세요.", text: $viewmodel.meals[index].foodList[mealIndex])
                        
                    Spacer()
                    
                    Button {
                        viewmodel.meals[index].foodList.remove(at: mealIndex)
                        
                    } label: {
                        Image(systemName: "xmark.circle")
                    }

                }
                .padding(10)
                .background(backgroundColor)
                .cornerRadius(10)

            }
            
            Button {
                viewmodel.meals[index].foodList.append("")
            } label: {
                HStack{
                    Spacer()
                    
                    Label {
                        Text("추가하기")
                    } icon: {
                        Image(systemName: "plus")
                    }
                    
                    Spacer()

                }
            }
            .buttonStyle(.plain)
            .padding(10)
            .background(backgroundColor)
            .cornerRadius(10)
        }
        
    }
}

struct MemoCreateView_Previews: PreviewProvider {
    static var previews: some View {
        MemoCreateView(viewmodel: MemoCreateViewModel(userid: "asdasd"))
    }
}

