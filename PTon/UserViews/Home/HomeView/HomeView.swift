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
            VStack{
                
                NavigationLink {
                    MemoListView(viewmodel: MemoListViewModel(trainerid: viewmodel.trainerid, userid: viewmodel.userid, userProfile: viewmodel.imageUrl),
                                 userName: viewmodel.username, trainerId: viewmodel.trainerid, trainerName: "트레이너")
                } label: {
                    Text("메모로")
                }
                .buttonStyle(.plain)

                
                
                UserProfileCardView()
                    .environmentObject(self.viewmodel)
                    .padding()
                    .onTapGesture {
                        self.isPresentProfile = true
                    }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack{
                        ForEach(1..<4) { item in
                            VStack{
                                Text("Example \(item)")
                                
                                Text("Example Chart \(item)")
                            }
                            .frame(width: 150, height: 150, alignment: .center)
                            .background(.purple)
                            .cornerRadius(20)
                        }
                    }
                }
                .padding()
                
                Text("example Pie Chart")
                    .frame(width: 350, height: 350, alignment: .center)
                    .background(.gray)
                    .cornerRadius(20)
                HStack{
                    VStack(alignment:.leading){
                        Text("회원권 이름")
                            .font(.title3)
                            .fontWeight(.heavy)
                        Text("회원권 기간")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("회원권 횟수")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("남은 횟수")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(.purple)
                .cornerRadius(20)
                .padding()
            }
        }
        .fullScreenCover(isPresented: $isPresentProfile,onDismiss: {
            viewmodel.reloadImage()
        }) {
            UserProfileView(image: URLImageView(urlString: viewmodel.imageUrl, imageSize: 300, youtube: false))
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

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView(image: URLImageView(urlString: "asdnk", imageSize: 300))
//    }
//}

