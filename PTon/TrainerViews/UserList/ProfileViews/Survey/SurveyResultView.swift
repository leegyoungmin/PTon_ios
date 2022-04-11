//
//  SurveyResultView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/02.
//

import SwiftUI

struct SurveyResultView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel:SurveyViewModel
    @Binding var isGoneMain:Bool
    @Binding var userScore:Int
    let typeList = ["Carbo","Protein","Fat"]
    var body: some View {
        ZStack{
            BackgroundView()
            
            VStack {
                VStack(spacing:10){
                    Text("설문조사 완료")
                        .foregroundColor(.white)
                        .padding(.bottom)
                    
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 100, height: 100, alignment: .center)
                        .cornerRadius(50)
                    
                    Text(viewModel.getUserType(result: userScore).rawValue)
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                    
                    HStack{
                        Image(systemName: "exclamationmark.square.fill")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        Text("적정 총 섭취 권장량은 \(viewModel.getResult(type: "All", result: userScore)) Kcal 입니다.")
                            .font(.body)
                            .foregroundColor(.white)
                        
                    }
                    .padding(5)
                    .border(.white)
                    
                }
                .padding(.top,20)
                
                TabView {
                    ForEach(typeList,id:\.self){ title in
                        pageDataView(title: title, data: viewModel.getResult(type: title, result: userScore))
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height:250)
                
                Spacer()
                
                Divider()
                
                HStack{
                    Spacer()
                    
                    Button("설문조사 다시하기") {
                        self.dismiss.callAsFunction()
                    }
                    Spacer()
                    
                    Divider()
                        .frame(height: 50, alignment: .center)
                    
                    Spacer()
                    
                    Button("메인으로 돌아가기"){
                        self.viewModel.SaveDataBase(userScore)
                        self.isGoneMain = true
                        self.dismiss.callAsFunction()
                    }
                    
                    Spacer()
                    
                }
                .foregroundColor(.accentColor)
            }
            
        }
    }
}

struct pageDataView:View{
    let title:String
    let data:String
    
    private func titleKor()->String{
        var titlekor = ""
        if self.title == "Carbo"{
            titlekor = "탄수화물"
        }
        
        if self.title == "Protein"{
            titlekor = "단백질"
        }
        
        if self.title == "Fat"{
            titlekor = "지방"
        }
        return titlekor
    }
    
    var body: some View{
        VStack(alignment: .leading, spacing: 10){
            Text(titleKor())
                .font(.title2)
                .foregroundColor(.accentColor)
            
            Text(data)
                .lineLimit(3)
                .font(.body)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width*0.9, height: 200)
        .background(.white)
        .cornerRadius(5)
        .shadow(color: .gray.opacity(0.5), radius: 5)
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
            SurveyResultView(viewModel: SurveyViewModel("", ""), isGoneMain: .constant(false), userScore: .constant(0))
            //            BackgroundView()
        }
    }
}
