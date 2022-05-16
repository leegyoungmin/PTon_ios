//
//  UserMemoView.swift
//  PTon
//
//  Created by 이경민 on 2022/04/03.
//

import Foundation
import SwiftUI

struct UserMemoView:View{
    @StateObject var viewmodel:UserMemoViewModel
    let userName:String
    let trainerId:String
    let trainerName:String
    var body: some View{
        VStack{
            List{
                ForEach(viewmodel.memos.filter{$0.isPrivate == false},id:\.self) { memo in
                    ZStack(alignment: .topLeading){
                        NavigationLink {
                            UserDetailMemoView(currentMemo: memo, viewModel: UserDetailMemoViewModel(
                                viewmodel.userId,
                                self.userName,
                                self.trainerId,
                                memo.uuid))
                                .onAppear {
                                    viewmodel.changeUnread(memo.uuid)
                                }
                        } label: {
                            EmptyView()
                        }
                        .buttonStyle(.plain)
                        .opacity(0.0)
                        
                        MemoListCellView(memo: memo, userId: viewmodel.userId, userName: self.userName, trainerId: viewmodel.trainerId)
                            .onTapGesture {
                                DispatchQueue.main.async {
                                    viewmodel.changeUnread(memo.uuid)
                                    viewmodel.memoChangeRead(memo.uuid)
                                }
                            }
                        
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 10, height: 10, alignment: .topLeading)
                            .offset(x:-10)
                            .opacity(memo.isRead ? 0:1)

                    }
                    .listStyle(.plain)
                    .listRowSeparator(.hidden)
                }
            }
            .padding()
            .listStyle(.plain)
            .listRowSeparator(.hidden)
        }
        .background(backgroundColor)
        .navigationTitle("공유된 메모")
        .navigationBarTitleDisplayMode(.large)
        .onDisappear {
            viewmodel.viewDisappear()
        }
        .onAppear {
            viewmodel.fetchData()
        }
    }
}

//struct UserMemoView_Previews:PreviewProvider{
//    static var previews: some View{
//        MemoListCellView(memo: Memo(uuid: UUID().uuidString, title: "asdnjk", content: "asdnk", time: "asdnjk", isPrivate: false, firstMeal: [""], secondMeal: [""], thirdMeal: [""], snack: [""]))
//    }
//}
