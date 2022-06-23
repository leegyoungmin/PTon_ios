//
//  BodyInfoPage.swift
//  PTon
//
//  Created by 이경민 on 2022/02/04.
//

import SwiftUI

struct BodyInfoPage: View {
    @StateObject var viewModel = BodyInfoViewModel()
    @ViewBuilder
    func titleView(_ title:String)->some View{
        HStack{
            Text(title)
                .font(.title2.bold())
                .foregroundColor(.black)
            
            Spacer()
        }
    }
    var body: some View{
        VStack{
            VStack{
                //height
                HStack{
                    titleView("키")
                    
                    Spacer()
                    
                    TextField("", text: $viewModel.height)
                        .padding(10)
                        .background(backgroundColor)
                        .cornerRadius(10)
                    
                    Text("cm")
                        .frame(maxWidth:30)
                }
                
                //weight
                HStack{
                    titleView("몸무게")
                    
                    Spacer()
                    
                    TextField("", text: $viewModel.weight)
                        .padding(10)
                        .background(backgroundColor)
                        .cornerRadius(10)
                    Text("kg")
                        .frame(maxWidth:30)
                }
                
                //Muscle
                HStack{
                    titleView("근골격근량")
                    
                    Spacer()
                    
                    TextField("", text: $viewModel.muscle)
                        .padding(10)
                        .background(backgroundColor)
                        .cornerRadius(10)
                    Text("kg")
                        .frame(maxWidth:30)
                }
                
                //Fat
                HStack{
                    titleView("체지방률")
                    
                    Spacer()
                    
                    TextField("", text: $viewModel.fat)
                        .padding(10)
                        .background(backgroundColor)
                        .cornerRadius(10)
                    Text("kg")
                        .frame(maxWidth:30)
                }
            }
            .padding(10)
            .background(.white)
            .cornerRadius(10)
            
            Spacer()
            
            Button {
                print(123)
            } label: {
                Text("저장하기")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.vertical,5)
            }
            .padding(5)
            .frame(width:UIScreen.main.bounds.width*0.8)
            .background(Color.accentColor)
            .cornerRadius(20)

        }
        .padding()
        .background(backgroundColor)
        .navigationTitle("신체정보 기입")
        .navigationBarTitleDisplayMode(.inline)
    }
}
struct BodyInfoPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            BodyInfoPage()
        }
    }
}
