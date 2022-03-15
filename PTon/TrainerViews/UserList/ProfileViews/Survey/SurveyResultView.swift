//
//  SurveyResultView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/02.
//

import SwiftUI

struct SurveyResultView: View {
    var body: some View {
        ZStack{
            BackgroundView()
            
            VStack {
                VStack(spacing:10){
                    Text("설문조사 완료")
                        .foregroundColor(.white)
                    
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 100, height: 100, alignment: .center)
                        .cornerRadius(50)
                    
                    Text("탄수화물형")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                    
                    Text("탄수화물형 설명이 들어가는 자리입니다.")
                        .font(.footnote)
                        .fontWeight(.regular)
                        .foregroundColor(.white)
                    
                }
                .padding(.bottom,50)
                .padding(.top,20)
                
                HStack{
                    Image(systemName: "exclamationmark.square.fill")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Text("적정 총 섭취 권장량은 2116.44 Kcal 입니다.")
                        .font(.body)
                        .foregroundColor(.white)
                }
                .padding(5)
                .border(.white)
                
                
                
                Text("Charts")
                    .frame(width: UIScreen.main.bounds.width*0.9, height: 200, alignment: .center)
                    .border(Color.accentColor)
                
                Spacer()
                
                Divider()
                
                HStack{
                    Spacer()
                    
                    Button("설문조사 다시하기") {
                        print("Restart")
                    }
                    Spacer()
                    
                    Divider()
                        .frame(height: 50, alignment: .center)
                    
                    Spacer()
                    
                    Button("메인으로 돌아가기"){
                        print("main Go")
                    }
                    
                    Spacer()
                    
                }
            }
            
        }
    }
}

struct BackgroundView:View{
    var body: some View{
        VStack{
            Color.accentColor
            Color.white
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct SurveyResultView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            SurveyResultView()
//            BackgroundView()
        }
    }
}
