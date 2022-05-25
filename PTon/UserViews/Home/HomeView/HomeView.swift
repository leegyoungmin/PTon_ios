//
//  HomeView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/15.
//

import SwiftUI
import Firebase
import Kingfisher
import PopupView

struct HomeView: View {
    @EnvironmentObject var viewmodel:UserBaseViewModel
    @State var isPresentProfile:Bool = false
    @StateObject var viewModel:HomeBodyViewModel = HomeBodyViewModel()
    
    @State var isWeightToastView:Bool = false
    @State var isFatToastView:Bool = false
    @State var isMuscleToastView:Bool = false
    var body: some View {
        ZStack{
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
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.white)
                        .cornerRadius(5)
                        .frame(height:250)
                        .shadow(color: .gray.opacity(0.2), radius: 5)
                    
                    VStack{
                        HStack{
                            UserBodyCellView(title: "몸무게",
                                             imageName: "defaultImage",
                                             data: viewModel.bodyDatas[.weight]?.last?.1 ?? 0,
                                             unit: "Kg",
                                             color: pink)
                            
                            Button {
                                isWeightToastView = true
                            } label: {
                                Image(systemName: "chevron.down")
                            }
                        }
                        
                        
                        Divider()
                        
                        //TODO: 체지방량 생성
                        HStack{
                            UserBodyCellView(title: "체지방량",
                                             imageName: "defaultImage",
                                             data: viewModel.bodyDatas[.fat]?.last?.1 ?? 0,
                                             unit: "%",
                                             color: sky)
                            
                            Button {
                                isFatToastView = true
                            } label: {
                                Image(systemName: "chevron.down")
                            }
                        }
                        
                        
                        Divider()
                        
                        //TODO: 골격근량 생성
                        HStack{
                            UserBodyCellView(title: "근골격근량",
                                             imageName: "defaultImage",
                                             data: viewModel.bodyDatas[.muscle]?.last?.1 ?? 0,
                                             unit: "Kg",
                                             color: yello)
                            
                            Button {
                                isMuscleToastView = true
                            } label: {
                                Image(systemName: "chevron.down")
                            }
                        }
                        
                        Divider()
                    }
                    
                    UserHomeMemberShipView()
                        .padding(.vertical)
                    
                    
                }
                .padding(.horizontal)
            }
            .disabled(isWeightToastView || isFatToastView || isMuscleToastView)
            .background(
                backgroundColor
            )
            .fullScreenCover(isPresented: $isPresentProfile) {
                UserProfileView()
                    .environmentObject(self.viewmodel)
            }
        }
        .popup(isPresented: $isWeightToastView,type: .default,dragToDismiss: false,closeOnTap: false,closeOnTapOutside: true) {
            let values = viewModel.bodyDatas[bodyDataType.weight]?.sorted(by: {$0.0<$1.0}) ?? []
            chartView(bodyDataType.weight,data: values)
                .padding()
        }
        .popup(isPresented: $isFatToastView,type: .default,dragToDismiss: false,closeOnTap: false,closeOnTapOutside: true) {
            let values = viewModel.bodyDatas[bodyDataType.fat]?.sorted(by: {$0.0<$1.0}) ?? []
            chartView(bodyDataType.fat,data: values)
                .padding()
        }
        .popup(isPresented: $isMuscleToastView,type: .default,dragToDismiss: false,closeOnTap: false,closeOnTapOutside: true) {
            let values = viewModel.bodyDatas[bodyDataType.muscle]?.sorted(by: {$0.0<$1.0}) ?? []
            chartView(bodyDataType.muscle,data: values)
                .padding()
        }
    }
}

struct UserProfileCardView:View{
    @EnvironmentObject var viewmodel:UserBaseViewModel
    var body: some View{
        HStack(spacing:6){
            
            CircleImage(url: viewmodel.userBaseModel.imageUrl ?? "", size: CGSize(width: 60, height: 60))
            
            
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

