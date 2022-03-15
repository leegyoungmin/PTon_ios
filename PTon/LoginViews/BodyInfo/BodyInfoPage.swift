//
//  BodyInfoPage.swift
//  PTon
//
//  Created by 이경민 on 2022/02/04.
//

import SwiftUI

struct BodyInfoPage: View {
    @ObservedObject var bodyViewModel = BodyInfoViewModel()
    @EnvironmentObject var errorHandle:ErrorHandling
    @Binding var isNavigatePast:Bool
    @State var userName:String
    @State var userEmail:String
    var body: some View {
        VStack{
            HStack{
                Text("회원 가입")
                    .font(.system(size: 30))
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.vertical,20)
            
            bodyCardView(title: "키", unit: "cm", value: $bodyViewModel.height)
            bodyCardView(title: "체중", unit: "kg", value: $bodyViewModel.weight)
            bodyCardView(title: "체지방률", unit: "%", value: $bodyViewModel.fat)
            bodyCardView(title: "골격근량", unit: "kg", value: $bodyViewModel.muscle)
            
            Button {
                print("Tapped Button")
                do{
                    try self.bodyViewModel.ValidValue()
                    self.bodyViewModel.uploadData {
                        self.isNavigatePast = false
                    }
                } catch{
                    self.errorHandle.handle(error: error)
                }
                
            } label: {
                HStack(alignment:.center){
                    Text("입력 완료")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 25))
                }
                .padding(.vertical,8)
                .padding(.horizontal)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(lineWidth: 2)
                )
                .foregroundColor(.purple)
            }
            .buttonStyle(.plain)
            .padding()
            
            Spacer()
        }
        .padding(.horizontal)
        .navigationTitle("신체 정보")
    }
}

struct bodyCardView:View{
    @State var title:String
    @State var unit:String
    @Binding var value:String
    var body: some View{
        HStack{
            Text(title)
                .foregroundColor(.black)
                .font(.title2)
                .fontWeight(.semibold)
            Spacer()
            TextField("", text: $value)
                .textFieldStyle(.roundedBorder)
                .frame(width: 100)
            Text(unit)
                .font(.title2)
                .fontWeight(.semibold)
        }
        .padding(.horizontal)
    }
}

struct BodyInfoPage_Previews: PreviewProvider {
    static var previews: some View {
        BodyInfoPage(isNavigatePast: .constant(true), userName: "이경민", userEmail: "cow970814@naver.com")
            .withErrorHandling()
    }
}
