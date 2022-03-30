//
//  UserBodyView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/31.
//

import Foundation
import SwiftUI

struct UserBodyView:View{
    @StateObject var viewModel:HomeBodyViewModel
    var body: some View{
        VStack{
            HStack{
                UserBodyCellView(title: "몸무게",
                                 imageName: "defaultImage",
                                 data: viewModel.userModel.bodyWeight ?? "",
                                 unit: "Kg",
                                 color: pink)
                
                Button {
                    print(123)
                } label: {
                    Image(systemName: "chevron.down")
                }
            }

            
            Divider()
            
            //TODO: 체지방량 생성
            HStack{
                UserBodyCellView(title: "체지방량",
                                 imageName: "defaultImage",
                                 data: viewModel.userModel.bodyFat ?? "",
                                 unit: "%",
                                 color: sky)
                
                Button {
                    print(123)
                } label: {
                    Image(systemName: "chevron.down")
                }
            }

            
            Divider()
            
            //TODO: 골격근량 생성
            HStack{
                UserBodyCellView(title: "근골격근량",
                                 imageName: "defaultImage",
                                 data: viewModel.userModel.bodyMuscle ?? "",
                                 unit: "Kg",
                                 color: yello)
                
                Button {
                    print(123)
                } label: {
                    Image(systemName: "chevron.down")
                }
            }
            
            Divider()
        }
    }
}

struct UserBodyCellView:View{
    let title:String
    let imageName:String
    let data:String
    let unit:String
    let color:Color
    var body: some View{
        HStack{
            Image(imageName)
                .resizable()
                .frame(width: 25, height: 25, alignment: .center)
                .padding(10)
                .background(color)
                .cornerRadius(5)
            
            Text(title)
                .font(.title3)
                .fontWeight(.light)
            
            Spacer()
            
            Text("\(data)\(unit)")
                .foregroundColor(.accentColor)
            
        }
    }
}

struct UserBodyView_previews:PreviewProvider{
    static var previews: some View{
        UserBodyView(viewModel: HomeBodyViewModel())
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
