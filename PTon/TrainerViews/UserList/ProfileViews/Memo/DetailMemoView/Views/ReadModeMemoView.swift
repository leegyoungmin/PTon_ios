//
//  ReadModeMemoView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/23.
//

import Foundation
import SwiftUI

struct ReadModeMemoView:View{
    //MARK: 1.PROPERTIES
    @EnvironmentObject var viewmodel:DetailMemoViewModel
    @Binding var currentMemo:Memo
    @State var commentText:String = ""
    @State var proxyIndex:Int = 0
    
    private func validationMeal() -> Bool{
        return (self.currentMemo.firstMeal.isEmpty) && (self.currentMemo.secondMeal.isEmpty) && (self.currentMemo.thirdMeal.isEmpty)
    }
    var body: some View{
        ScrollView {
            ScrollViewReader { proxy in
                VStack(alignment:.leading,spacing:5){
                    
                    Text(currentMemo.time.replacingOccurrences(of: "-", with: "."))
                        .font(.callout)
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text(currentMemo.content)
                        .font(.body)
                        .fontWeight(.regular)
                        .foregroundColor(.gray.opacity(0.9))
                        .padding(.top)
                        .multilineTextAlignment(.leading)
                        .frame(minHeight:200,alignment: .top)
                    
                    
                    
                    //MARK: FOOD SECTION
                    if !validationMeal(){
                        Text("식단")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.vertical)
                        
                        Group{
                            MemoMealCellView(title:"아침",meals: currentMemo.firstMeal)
                            
                            MemoMealCellView(title:"점심",meals: currentMemo.secondMeal)
                            
                            MemoMealCellView(title:"간식",meals: currentMemo.snack)
                            
                            MemoMealCellView(title:"저녁",meals: currentMemo.thirdMeal)
                        }
                        .padding(.bottom,10)
                    }
                    
                    Divider()
                        .padding(.vertical)
                    
                    if currentMemo.isPrivate == false{
                        //MARK: - COMMENT SECTION
                        //comment List에 대한 분기처리
                        if !viewmodel.commentList.isEmpty{
                            VStack(spacing:20){
                                ForEach(viewmodel.commentList.sorted(by: {$0.time >= $1.time}).indices,id:\.self) { index in
                                    MemoCommentCellView(comment: viewmodel.commentList[index])
                                        .id(index+1)
                                        .environmentObject(self.viewmodel)
                                        .onAppear {
                                            print("\(index) ::: \(viewmodel.commentList.sorted(by: {$0.time >= $1.time})[index])")
                                        }
                                }
                                
                            }
                            .padding(.bottom)
                            
                        }else{
                            VStack{
                                Text("아직 작성된 댓글이 없습니다.")
                            }
                            .padding(.bottom)
                        }
                    }
                }
                .padding(.horizontal)
                .onChange(of: proxyIndex) { newValue in
                    //proxy index 변경처리를 통한 스크롤 컨트롤
                    withAnimation {
                        
                        print(newValue)
                        
                        if newValue < 0{
                            UIApplication.shared.endEditing()
                        }else{
                            proxy.scrollTo(newValue, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .navigationTitle(currentMemo.title)
        .navigationBarTitleDisplayMode(.large)
        .onTapGesture {
            proxyIndex = -1
        }
        
        if currentMemo.isPrivate == false{
            //MARK: - 댓글 작성
            VStack{
                Divider()
                
                HStack{
                    
                    TextField("댓글 달기", text: $commentText)
                        .textFieldStyle(.plain)
                        .onTapGesture {
                            proxyIndex = viewmodel.commentList.endIndex
                        }
                    
                    Button {
                        DispatchQueue.main.async {
                            viewmodel.setCommentData(commentText)
                            commentText = ""
                        }
                    } label: {
                        Image(systemName: "paperplane.fill")
                    }
                    .buttonStyle(.plain)
                    .tint(Color.accentColor)
                    
                }
                .padding([.horizontal,.bottom])
                .padding(.top,5)
                
            }
        }
    }
}

//MARK: - 댓글 셀 뷰
struct MemoCommentCellView:View{
    @EnvironmentObject var viewModel:DetailMemoViewModel
    let comment:comment
    @State var stringTime:String = ""
    var body: some View{
        HStack{
            
            if viewModel.isTrainer(){
                Image("defaultImage")
                    .resizable()
                    .frame(width: 50, height: 50, alignment: .center)
                    .clipShape(Circle())
                    .background(
                        Circle()
                            .stroke(backgroundColor,lineWidth: 2)
                    )
            }
            else{
                URLImageView(urlString: viewModel.userProfile, imageSize: 50, youtube: false)
            }
            
            VStack(alignment:.leading,spacing:5){
                CommentLabel(name: comment.writerName, comment: comment.content)
                
                HStack{
                    //MARK: - 댓글 작성 시간 및 현재 시간 비교 후 일수 및 시간 작성
                    Text(stringTime)
                        .onAppear {
                            viewModel.caculateDate(comment, completion: { stringTime in
                                self.stringTime = stringTime
                            })
                        }
                    
                    if viewModel.isWriter(comment.writerId){
                        Button {
                            viewModel.deleteData(comment: comment)
                        } label: {
                            Text("삭제하기")
                                .foregroundColor(.red)
                        }
                    }
                }
                .font(.footnote)
            }
            //MARK: - 댓글 더보기
            
            Spacer()
            
            Button {
                viewModel.toggleLike(comment: comment)
            } label: {
                Image(systemName: comment.isLike ? "heart.fill":"heart")
            }
            .disabled(viewModel.isWriter(comment.writerId))
            
        }
    }
    
    @ViewBuilder
    private func CommentLabel(name:String,comment:String)->some View{
        Text(name).fontWeight(.semibold) + Text("  ") + Text(comment).font(.footnote)
    }
}

//MARK: - 메모 식사 셀 뷰
struct MemoMealCellView:View{
    let title:String
    let meals:[String]
    var body: some View{
        
        VStack(alignment: .leading, spacing: 10){
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            if meals.isEmpty{
                HStack{
                    Spacer()
                    
                    Text("\(title)에 지정된 음식이 없습니다.")
                    
                    Spacer()
                }

            }else{
                ForEach(meals,id:\.self) { meal in
                    HStack{
                        Text(meal)
                            .foregroundColor(.accentColor)
                        Spacer()
                    }
                    .padding(10)
                    .background(Color("Background"))
                    .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal)
    }
}
