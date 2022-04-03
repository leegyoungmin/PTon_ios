//
//  UserMemoView.swift
//  PTon
//
//  Created by 이경민 on 2022/04/03.
//

import Foundation
import SwiftUI

struct UserMemoView:View{
    @StateObject var viewmodel:MemoListViewModel
    let userName:String
    let trainerId:String
    let trainerName:String
    var body: some View{
        List{
            ForEach(viewmodel.memos.filter{$0.isPrivate == false},id:\.self) { memo in
                ZStack{
                    NavigationLink {
                        DetailMemoView(viewmodel: DetailMemoViewModel(userId: viewmodel.userid, userName: userName, trainerId: trainerId, trainerName: trainerName, memoId: memo.uuid, userProfile: viewmodel.userProfile), currentMemo:memo)
                    } label: {
                        EmptyView()
                    }
                    .buttonStyle(.plain)
                    .opacity(0.0)
                    
                    MemoListCellView(memo: memo)

                }
            }
            .onDelete { indexset in
                guard let index = indexset.first else{return}
                viewmodel.deleteData(data: viewmodel.memos.filter{$0.isPrivate == false}[index])
            }
            
        }
        .listStyle(.plain)
        .listRowSeparator(.hidden)
        .navigationTitle("공유된 메모")
        .navigationBarTitleDisplayMode(.large)
    }
}
