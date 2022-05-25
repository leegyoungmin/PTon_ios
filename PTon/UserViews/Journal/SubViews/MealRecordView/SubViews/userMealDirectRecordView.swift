//
//  userMealDirectRecordView.swift
//  PTon
//
//  Created by 이경민 on 2022/05/25.
//

import SwiftUI

struct userMealDirectRecordView: View {
    //MARK: - PROPERTIES
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel:UserMealViewModel
    @State var foodName:String = ""
    @State var foodKcal:String = ""
    @State var foodGram:String = ""
    @State var foodCarbs:String = ""
    @State var foodProtein:String = ""
    @State var foodFat:String = ""
    
    //MARK: - BODY
    var body: some View {
        NavigationView{
            ScrollView(.vertical, showsIndicators: false) {
                VStack{
                    DirectRecordTitleView(title: "사진")
                        .padding(.vertical)
                    //1. 사진 기록하기
                    RoundedRectangle(cornerRadius: 15)
                        .frame(height:UIScreen.main.bounds.width/2)
                        .foregroundColor(backgroundColor)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 50))
                                .foregroundColor(.accentColor)
                        )
                        .onTapGesture {
                            print(123)
                        }
                    
                    DirectRecordTitleView(title: "영양정보")
                        .padding(.vertical)
                    
                    //2. 메뉴명
                    TextField("", text: $foodName)
                        .textFieldStyle(DirectMealTextFieldStyle(title: "메뉴명",unit: nil))
                    //3. 칼로리
                    TextField("", text: $foodKcal)
                        .textFieldStyle(DirectMealTextFieldStyle(title: "칼로리정보",unit: "kcal"))
                    
                    //4. 1인분
                    TextField("", text: $foodGram)
                        .textFieldStyle(DirectMealTextFieldStyle(title: "1인분", unit: "g"))
                    
                    //5. 탄수화물,단백질,지방 기록
                    VStack{
                        HStack(alignment:.center){
                            Text("탄수화물")
                                .fontWeight(.semibold)
                            Spacer()
                            
                            TextField("", text: $foodCarbs)
                                .padding(.vertical,3)
                                .frame(width:50)
                                .background(backgroundColor)
                                .cornerRadius(5)
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                            Text("g")
                        }
                        
                        HStack(alignment:.center){
                            Text("단백질")
                                .fontWeight(.semibold)
                            Spacer()
                            
                            TextField("", text: $foodProtein)
                                .padding(.vertical,3)
                                .frame(width:50)
                                .background(backgroundColor)
                                .cornerRadius(5)
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                            Text("g")
                        }
                        
                        HStack(alignment:.center){
                            Text("지방")
                                .fontWeight(.semibold)
                            Spacer()
                            
                            TextField("", text: $foodFat)
                                .padding(.vertical,3)
                                .frame(width:50)
                                .background(backgroundColor)
                                .cornerRadius(5)
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                            Text("g")
                        }
                    }
                    .padding(.vertical)
                }
                .padding(.horizontal)
                .navigationTitle("식사 추가")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss.callAsFunction()
                        } label: {
                            Text("취소")
                        }

                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            print(123)
                        } label: {
                            Text("음식 저장")
                        }

                    }
            }
            }
        }

    }
}

//MARK: - SUBVIEWS
struct DirectRecordTitleView:View{
    let title:String
    var body: some View{
        HStack{
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
        }
        .padding(.vertical,5)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .frame(height:1)
            ,alignment: .bottom
        )
    }
}

struct DirectMealTextFieldStyle:TextFieldStyle{
    let title:String
    let unit:String?
    func _body(configuration:TextField<Self._Label>)-> some View{
        VStack(alignment:.leading,spacing:10){
            Text(title)
                .fontWeight(.semibold)
            HStack{
                configuration
                
                if unit != nil{
                    Text(unit!)
                        .multilineTextAlignment(.trailing)
                        .padding(.trailing,10)
                }
            }
            .padding(8)
            .background(backgroundColor)
            .cornerRadius(10)

        }
    }
}

//MARK: - PREVIEWS
struct userMealDirectRecordView_Previews: PreviewProvider {
    static var previews: some View {
        userMealDirectRecordView()
    }
}
