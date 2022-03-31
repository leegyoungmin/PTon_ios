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
                        isPresentProfile = true
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
                
//                ExampleView()
                RoundedRectangle(cornerRadius: 5)
                    .fill(.white)
                    .cornerRadius(5)
                    .frame(height:250)
                    .shadow(color: .gray.opacity(0.2), radius: 5)
                
                UserBodyView()
                
                UserHomeMemberShipView()
                    .padding(.vertical)
                
                
            }
            .padding(.horizontal)
        }
        .background(
            Rectangle()
                .fill(
                    LinearGradient(gradient: Gradient(stops: [
                        Gradient.Stop(color: .white, location: 0.3),
                        Gradient.Stop(color: backgroundColor, location: 0.3)
                    ]), startPoint: .top, endPoint: .bottom)
                )
                .edgesIgnoringSafeArea(.all)
            
        )
        .fullScreenCover(isPresented: $isPresentProfile) {
            UserProfileView()
                .environmentObject(self.viewmodel)
        }
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
        //        backgroundView()
        
    }
}

