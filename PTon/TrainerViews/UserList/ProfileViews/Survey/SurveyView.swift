//
//  SurveyView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/11.
//

import SwiftUI
import ToastUI

struct SurveyView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var profileViewModel:ProfileViewModel
    @StateObject var surveyViewModel:SurveyViewModel
    @State var userScore = 0
    @State var isShowAlertView:Bool = false
    @State var isPresentView:Bool = false
    @State var isGoMain:Bool = false
    
    @State var UserType:String = ""
    @State var UserMessage:String = ""
    let questions:[Question] = Bundle.main.decode("SurvayData.json")
    var body: some View {
        TabView{
            ForEach(questions.indices,id:\.self) { index in
                QuestionCell(index: index, question: questions[index], userScore: $userScore)
            }
            
            Text("저장하고 결과보기")
                .padding(10)
                .foregroundColor(.white)
                .background(Color.accentColor)
                .cornerRadius(30)
                .onTapGesture {
                    isPresentView = true
                }
            
            
        }
        .background(Color("Background").edgesIgnoringSafeArea(.all))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .tabViewStyle(PageTabViewStyle())
        .navigationTitle("설문조사")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if profileViewModel.result.allKcal != ""{
                self.isPresentView = true
            }
        }
        .fullScreenCover(isPresented: $isPresentView) {
            if isGoMain == true{
                self.presentationMode.wrappedValue.dismiss()
            }
        } content: {
            SurveyResultView(viewModel: self.surveyViewModel,isGoneMain:$isGoMain, userScore: $userScore)
        }
        
    }
    
}

struct QuestionCell:View{
    let index:Int
    let question:Question
    
    @State var isSelectedOne:Bool = false
    @State var isSelectedTwo:Bool = false
    @Binding var userScore:Int
    var body: some View{
        VStack{
            Text("Question\(index+1)")
                .foregroundColor(.white)
                .padding(10)
                .background(Color.accentColor)
                .cornerRadius(30)
            
            Text(question.question)
                .multilineTextAlignment(.center)
                .font(.title3)
                .frame(width: UIScreen.main.bounds.width*0.8, alignment: .center)
                .padding(.bottom,30)
            
            
            Button {
                if isSelectedTwo == true{
                    userScore += 2
                }else{
                    if isSelectedOne == false{
                        userScore += 1
                    }
                }
                
                isSelectedTwo = false
                isSelectedOne.toggle()
                
                print("tapped One \(userScore)")
            } label: {
                HStack{
                    Text(question.answer1)
                        .foregroundColor(isSelectedOne ? Color.accentColor:.gray)
                        .font(.system(size: 14))
                    
                    Spacer()
                    
                    Image(systemName: isSelectedOne ? "circle.fill":"circle")
                        .font(.body)
                        .foregroundColor(isSelectedOne ? Color.accentColor:.gray)
                }
                .padding()
                .background(.white)
            }
            .buttonStyle(.plain)
            .frame(width: UIScreen.main.bounds.width*0.9)
            .tint(.accentColor)
            
            Button {
                if isSelectedOne == true{
                    userScore -= 2
                }else{
                    if isSelectedTwo == false{
                        userScore -= 1
                    }
                }
                
                isSelectedOne = false
                isSelectedTwo.toggle()
                
                print("tapped two \(userScore)")
            } label: {
                HStack{
                    Text(question.answer2)
                        .foregroundColor(isSelectedTwo ? Color.accentColor:.gray)
                        .font(.system(size: 14))
                    
                    Spacer()
                    
                    Image(systemName: isSelectedTwo ? "circle.fill":"circle")
                        .font(.body)
                        .foregroundColor(isSelectedTwo ? Color.accentColor:.gray)
                }
                .padding()
                .background(.white)
            }
            .buttonStyle(.plain)
            .frame(width: UIScreen.main.bounds.width*0.9)
        }
        .padding(.bottom,50)
    }
}

struct QuestionCellView:View{
    @State var question:Question
    @State var isSelectedOne:Bool = false
    @State var isSelectedTwo:Bool = false
    @Binding var userScore:Int
    var body: some View{
        GeometryReader{proxy in
            VStack{
                
                Text(question.question)
                    .font(.system(size: 18))
                    .padding()
                    .multilineTextAlignment(.center)
                
                Button {
                    if isSelectedTwo == true{
                        userScore += 2
                    }else{
                        userScore += 1
                    }
                    
                    isSelectedTwo = false
                    isSelectedOne.toggle()
                    
                    print("tapped One \(userScore)")
                } label: {
                    Text(question.answer1)
                        .font(.system(size: 13))
                        .padding()
                        .frame(width: proxy.size.width*0.9)
                        .background(isSelectedOne ? .purple:.white)
                        .foregroundColor(isSelectedOne ? .white:.black)
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(isSelectedOne ? .purple:.black, lineWidth: 2)
                        )
                        .multilineTextAlignment(.center)
                }
                .buttonStyle(.plain)
                
                
                Button {
                    
                    if isSelectedOne == true{
                        userScore -= 2
                    }else{
                        userScore -= 1
                    }
                    
                    isSelectedOne = false
                    isSelectedTwo.toggle()
                    
                    print("tapped two \(userScore)")
                } label: {
                    Text(question.answer2)
                        .font(.system(size: 13))
                        .padding()
                        .frame(width: proxy.size.width*0.9)
                        .background(isSelectedTwo ? .purple:.white)
                        .foregroundColor(isSelectedTwo ? .white:.black)
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(isSelectedTwo ? .purple:.black, lineWidth: 2)
                        )
                        .multilineTextAlignment(.center)
                }
                .buttonStyle(.plain)
                
            }
            .position(x: proxy.size.width/2, y: proxy.size.height/2)
        }
        
    }
}

struct SurveyView_Previews: PreviewProvider {
    static let questions:[Question] = Bundle.main.decode("SurvayData.json")
    static var previews: some View {
        SurveyView(surveyViewModel: SurveyViewModel("example", "example"))
        //        QuestionCell(index: 12, question: questions[2], userScore: .constant(0))
    }
}
