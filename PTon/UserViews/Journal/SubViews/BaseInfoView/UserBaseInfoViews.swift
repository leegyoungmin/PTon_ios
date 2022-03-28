//
//  UserBaseInfoViews.swift
//  PTon
//
//  Created by 이경민 on 2022/03/24.
//

import Foundation
import SwiftUI
import AlertToast

struct UserBaseInfoView:View{
    @StateObject var viewModel:UserBaseInfoViewModel
    @Binding var selectedDate:Date
    @State var isSuccess:Bool = false
    var body: some View{
        VStack{
            
            HStack{
                
                Text("나의 신체정보")
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    UIApplication.shared.endEditing()
                    viewModel.updateValue(selectedDate)
                    isSuccess = true
                } label: {
                    Text("저장")
                        .fontWeight(.light)
                        .foregroundColor(.white)
                        .padding(.horizontal,10)
                        .padding(.vertical,5)
                        .background(Color.accentColor)
                        .cornerRadius(20)
                }
                .buttonStyle(.plain)

            }//:HSTACK
            .padding(.horizontal)
            .padding(.top)
            
            Divider()
                .padding(.horizontal)
            
            BaseInfoElementView(pink, "몸무게", $viewModel.weightText, unit: "Kg")
            
            
            Divider()
                .padding(.horizontal)
            BaseInfoElementView(sky, "체지방률", $viewModel.fatText, unit: "%")
            
            
            Divider()
                .padding(.horizontal)
            
            BaseInfoElementView(yello, "근골격근량", $viewModel.muscleText, unit: "Kg")
            
        }
        .background(.white)
        .cornerRadius(5)
        .shadow(color: .gray.opacity(0.5), radius: 3)
        .onChange(of: selectedDate) { newValue in
            viewModel.readData(newValue)
        }
        .toast(isPresenting: $isSuccess) {
            AlertToast(displayMode: .banner(.pop), type: .complete(.accentColor),title: "저장 완료",style: .style(titleColor: .accentColor))
        }
    }
    
    @ViewBuilder
    func BaseInfoElementView(_ color:Color,_ title:String,_ dataString:Binding<String>,unit:String) -> some View{
        HStack{
            Image("defaultImage")
                .resizable()
                .frame(width: 30, height: 30, alignment: .leading)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color)
                )
            
            Text(title)
            Spacer()
            
            TextField("", text: dataString)
                .frame(width:50)
                .multilineTextAlignment(.center)
            
            Text(unit)
                .frame(width:30)
        }
        .padding(.horizontal)
        .padding(.bottom,10)
    }
}

struct userBaseInfoView_Previews:PreviewProvider{
    static var previews: some View{
        UserBaseInfoView(viewModel: UserBaseInfoViewModel("kakao:1967260938"), selectedDate: .constant(Date()))
            .previewLayout(.sizeThatFits)
            .padding()
            .background(backgroundColor)
    }
}
