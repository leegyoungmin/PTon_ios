//
//  MemberShipView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/14.
//

import SwiftUI

struct MemberShipView: View {
    @StateObject var ViewModel:MembershipViewModel
    var body: some View {
        VStack(spacing:20){
            Spacer()
            GroupBox(content: {
                DatePicker("시작 날짜", selection: $ViewModel.startDate, displayedComponents: .date)
                DatePicker("종료 날짜", selection: $ViewModel.endDate, in: ViewModel.startDate...,displayedComponents: .date)
                
                VStack{
                    Stepper("수업 횟수", value: $ViewModel.Times, step: 1)
                    HStack{
                        Spacer()
                        Text("\(ViewModel.Times)")
                    }
                }
                
                VStack{
                    Stepper("수업한 횟수", value: $ViewModel.usedTimes, in: 0...ViewModel.Times,step: 1)
                    HStack{
                        Spacer()
                        Text("\(ViewModel.usedTimes)")
                    }
                }
            })
            
            Spacer()
            
            Button {
                ViewModel.SaveData()
            } label: {
                Text("저장하기")
            }
            .buttonStyle(.bordered)
            Spacer()


        }
        .environment(\.locale, Locale(identifier: "ko_KR"))
        .padding()
    }
}

struct MemberShipView_Previews: PreviewProvider {
    static var previews: some View {
        MemberShipView(ViewModel: MembershipViewModel(trainerid: "example", userid: "example"))
    }
}

