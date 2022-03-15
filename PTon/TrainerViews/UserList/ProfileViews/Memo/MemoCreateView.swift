//
//  MemoCreateView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/12.
//

import SwiftUI
import AlertToast

enum mealType:String,CaseIterable{
    case first = "아침"
    case second = "점심"
    case third = "저녁"
}

struct MemoCreateView: View {
    @StateObject var viewmodel : MemoCreateViewModel
    @State var isPrivate : Bool = false
    @State var title:String = ""
    @State var content:String = "내용을 입력해주세요."
    @State var MealCount:Int = 0
    @State var selectedIndex = 1
    
    init(viewmodel:MemoCreateViewModel){
        _viewmodel = StateObject.init(wrappedValue: viewmodel)
        UITextView.appearance().backgroundColor = .clear
    }
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            VStack{
                
                TextField("제목을 입력하세요.", text: $title)
                    .font(.title)
                    .padding(.vertical)
                
                
                GroupBox{
                    Toggle(isOn: $isPrivate) {
                        Text("비공개 설정")
                    }
                }
                
                
                GroupBox {
                    
                    TextEditor(text: $content)
                        .foregroundColor(content == "내용을 입력해주세요." ? .gray:.black)
                        .background(.clear)
                        .frame(minHeight:100,maxHeight:300)
                        .onTapGesture {
                            if content == "내용을 입력해주세요."{
                                content = ""
                            }
                        }
                } label: {
                    HStack(){
                        Text("메모")
                            .font(.title2)
                        Spacer()
                    }
                }
                
                GroupBox {
                    VStack{
                        ForEach(0...MealCount,id:\.self){index in
                            mealCellView(mealIndex: index, mealCount: $MealCount)
                                .environmentObject(self.viewmodel)
                        }
                        
                        Button {
                            MealCount += 1
                        } label: {
                            Text("추가하기")
                        }
                        .disabled(MealCount == 2)

                    }
                } label: {
                    HStack(){
                        Text("식단")
                            .font(.title2)
                        Spacer()
                    }
                }
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
                        
                        let data = memo(isprivate:isPrivate,title: title, content: content, meal: viewmodel.meals)
                        
                        viewmodel.updateData(data: data)
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
    let titles = ["아침","점심","저녁"]
    let mealIndex:Int
    @State var mealText = ""
    @Binding var mealCount:Int
    var body: some View{
        VStack {
            HStack{
                Text("\(titles[mealIndex])")
                    .foregroundColor(.accentColor)
                Spacer()
                
                Button {
                    if mealCount != 0{
                        mealCount -= 1
                    }
                } label: {
                    Image(systemName: "xmark.circle")
                }

            }
            TextEditor(text: $mealText)
                .frame(minHeight:40)
        }
        .padding()
        .background(.white)
        .cornerRadius(10)
        .onChange(of: mealText) { newValue in
            print("Memo Create View  new Value : \(newValue)")
            viewmodel.meals[mealIndex].foodList = mealText.components(separatedBy: ",")
            print("Memo Create View model meals : \(viewmodel.meals)")
        }
    }
}

struct MemoCreateView_Previews: PreviewProvider {
    static var previews: some View {
        MemoCreateView(viewmodel: MemoCreateViewModel(userid: "asdasd"))
    }
}

