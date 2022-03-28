//
//  HomeView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/15.
//

import SwiftUI
import Firebase

struct HomeView: View {
    @EnvironmentObject var viewmodel:UserBaseViewModel
    @State var isPresentProfile:Bool = false
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false){
            VStack(spacing:10){
                HStack{
                    Text("\(viewmodel.username)님")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button {
                        print(123)
                    } label: {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.title)
                    }

                }
                .padding(.top,20)
                
                HStack{
                    Text("트레이너와 체질 설문조사를 완료하세요.")
                        .font(.system(size: 18))
                        .fontWeight(.light)
                    
                    Spacer()
                }
                
                //TODO: 그래프 생성
                RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .frame(height:200)
                .padding()
                .background(.white)
                .cornerRadius(5)
                .shadow(color: .gray.opacity(0.2), radius: 5)
                
                
                VStack{
                    HStack{
                        Image("defaultImage")
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .center)
                            .padding(10)
                            .background(pink)
                            .cornerRadius(5)
                        
                        Text("몸무게")
                            .font(.title3)
                            .fontWeight(.light)
                        
                        Spacer()
                        
                        Text("48Kg")
                            .foregroundColor(.accentColor)
                    }
                    
                    Divider()
                }
                
                //TODO: 체지방량 생성
                VStack{
                    HStack{
                        Image("defaultImage")
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .center)
                            .padding(10)
                            .background(sky)
                            .cornerRadius(5)
                        
                        Text("몸무게")
                            .font(.title3)
                            .fontWeight(.light)
                        
                        Spacer()
                        
                        Text("48Kg")
                            .foregroundColor(.accentColor)
                    }
                    
                    Divider()
                }
                
                //TODO: 골격근량 생성
                VStack{
                    HStack{
                        Image("defaultImage")
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .center)
                            .padding(10)
                            .background(yello)
                            .cornerRadius(5)
                        
                        Text("몸무게")
                            .font(.title3)
                            .fontWeight(.light)
                        
                        Spacer()
                        
                        Text("48Kg")
                            .foregroundColor(.accentColor)
                    }
                    
                    Divider()
                }
                
                //TODO: PT권 데이터 설정
                HStack{
                    Text("PT 5개월 10회 (D-147)")
                        .font(.title3)
                        .fontWeight(.light)
                    
                    Spacer()
                    
                    Button {
                        print(123)
                    } label: {
                        Text("사용중")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal,10)
                            .padding(.vertical,5)
                            .background(Color.accentColor)
                            .cornerRadius(20)
                    }
                    .buttonStyle(.plain)

                }
                
                //TODO: LAZYVGRID 설정
                VStack{
                    HStack(alignment:.center){
                        Text("기간")
                        Spacer()
                        Spacer()
                        Text("세션")
                        Spacer()
                        Text("계약일")
                    }
                    Divider()
                    HStack{
                        Text("2022.03.08 ~ 2022.04.08")
                            .font(.caption)
                        Spacer()
                        Text("20")
                            .font(.caption)
                        Spacer()
                        Text("2022.03.08")
                            .font(.caption)
                        
                    }
                }
                .padding()
                .background(.white)
                .cornerRadius(5)
                
                
            }
            .padding(.horizontal)
        }
        .background(backgroundColor.edgesIgnoringSafeArea(.all))
    }
}

struct UserProfileCardView:View{
    @EnvironmentObject var viewmodel:UserBaseViewModel
    var body: some View{
        HStack(spacing:6){
            
            URLImageView(urlString: viewmodel.userBaseModel.imageUrl, imageSize: 60, youtube: false)
            
            VStack(alignment:.leading){
                Text(viewmodel.username)
                    .font(.title)
                    .fontWeight(.heavy)
                
                Text("User Type in Survey")
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(UserBaseViewModel())
    }
}

