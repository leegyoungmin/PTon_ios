//
//  MemberShipView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/31.
//

import Foundation
import SwiftUI

struct UserHomeMemberShipView:View{
    let gridItems = [GridItem(.flexible(minimum:160)),GridItem(.flexible(maximum:50)),GridItem(.flexible(minimum:100))]
    @StateObject var viewModel = UserHomeMemberShipViewModel()
    var body: some View{
        
        VStack {
            HStack{
                if viewModel.expirationPeriod() < 0{
                    Text("PT 기간 만료")
                        .font(.title3)
                        .fontWeight(.light)
                        .onAppear {
                            print("viewmode expiration period \(viewModel.expirationPeriod())")
                        }

                }else if viewModel.expirationPeriod() == 0{
                    Text("PT 기간 만료 예정")
                        .font(.title3)
                        .fontWeight(.light)
                }else if viewModel.expirationNumber() == true{
                    Text("PT 횟수 종료")
                        .font(.title3)
                        .fontWeight(.light)
                }
                else if viewModel.expirationPeriod() > 0{
                    Text("PT \(viewModel.settingDate[0])개월 10회 (D-\(viewModel.settingDate[1]))")
                        .font(.title3)
                        .fontWeight(.light)
                }
                
                Spacer()
                
                if viewModel.expirationPeriod() < 0 || viewModel.expirationNumber() == true{
                    Text("")
                }else{
                    Text("사용중")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal,10)
                        .padding(.vertical,5)
                        .background(Color.accentColor)
                        .cornerRadius(20)
                }
                
            }
            VStack(alignment:.center){
                
                LazyVGrid(columns: gridItems) {
                    Text("기간")
                        .fontWeight(.light)
                        .font(.callout)
                    
                    Text("세션")
                        .fontWeight(.light)
                        .font(.callout)
                    
                    Text("계약일")
                        .fontWeight(.light)
                        .font(.callout)
                }
                
                Divider()
                
                LazyVGrid(columns: gridItems) {
                    
                    if viewModel.memberShip.endDate != nil,
                       viewModel.memberShip.startDate != nil{
                        Text("\(viewModel.memberShip.startDate!) ~ \(viewModel.memberShip.endDate!)")
                    }else{
                        Text("-")
                    }
                    
                    if viewModel.memberShip.ptTimes != nil{
                        Text("\(viewModel.memberShip.ptTimes!)")
                    }else{
                        Text("-")
                    }

                    Text("2022.03.08")
                }
                .font(.footnote)
                .foregroundColor(.gray.opacity(0.7))
            }
            .padding()
            .background(.white)
            .cornerRadius(5)
            .shadow(color: .gray.opacity(0.5), radius: 5)
        }
    }
}

struct UserHomeMemberShipView_previews:PreviewProvider{
    static var previews: some View{
        UserHomeMemberShipView()
            .previewLayout(.sizeThatFits)
            .background(backgroundColor)
            .padding()
    }
}
