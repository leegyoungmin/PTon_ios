//
//  TrainerUserLIstView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/08.
//

import SwiftUI

struct TrainerUserListView: View {
    @EnvironmentObject var baseViewmodel:TrainerBaseViewModel
    @StateObject var trainerUserListViewModel = TrainerUserListViewModel()
    @State var isShowSheet:Bool = false
    @State var isChatClicked:Bool = false
    @State var isPresentChat:Bool = false
    @State var userindex:Int = 0
    @State var searchText:String = ""
    @Binding var baseIndex:Int
    var body: some View {
        
        ZStack{
            Color("Background").edgesIgnoringSafeArea(.all)
            
            VStack{
                HStack{
                    TextField("회원의 이름을 검색해주세요.", text: $searchText)
                        .textFieldStyle(.plain)
                    Image(systemName: "magnifyingglass")
                }
                .padding()
                .background(.white)
                .cornerRadius(3)
                .shadow(color: Color(uiColor: UIColor.lightGray).opacity(0.1), radius: 1, x: 1, y: 1)
                .padding(.top,20)
                
                HStack{
                    Text("현재회원목록")
                        .font(.system(size: 20))
                        .fontWeight(.light)
                    Spacer()
                    NavigationLink {
                        UserAddView()
                    } label: {
                        HStack{
                            Text("회원추가")
                                .foregroundColor(.accentColor)
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top,20)
                
                List(trainerUserListViewModel.trainees.indices,id:\.self){ index in
                    userListRowView(item: trainerUserListViewModel.trainees[index])
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                self.trainerUserListViewModel.removeUser(index: index)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .tint(.red)
                        }
                        .onTapGesture {
                            print(trainerUserListViewModel.trainees)
                            self.userindex = index
                            self.isShowSheet = true
                        }
                        .fullScreenCover(isPresented: $isShowSheet, onDismiss: DidDissMiss) {
                            ProfileView(
                                viewmodel: ProfileViewModel(baseViewmodel.trainerId,
                                                            trainerUserListViewModel.fitnessCode,
                                                            baseViewmodel.trainerbasemodel.trainee[userindex]
                                                           ),
                                ispresent: $isShowSheet,
                                isChatting: $isPresentChat,
                                index: $baseIndex,
                                trainerName: baseViewmodel.trainername)
                        }
                }
                .listStyle(.plain)
                .searchable(text: $searchText)
                
                NavigationLink(isActive: $isPresentChat) {
                    LazyView(
                        ChatView(viewModel: ChattingInputViewModel(baseViewmodel.trainerId,
                                                                   trainerName: baseViewmodel.trainername,
                                                                   trainerUserListViewModel.userid(userindex),
                                                                   userName: trainerUserListViewModel.trainees[userindex].userName,
                                                                   baseViewmodel.fitnessCode),
                                 userProfileImage: trainerUserListViewModel.trainees[userindex].userProfile)
                        .environmentObject(ChattingViewModel(trainee: trainerUserListViewModel.trainees[userindex],
                                                             baseViewmodel.trainerId,
                                                             baseViewmodel.trainername,
                                                             baseViewmodel.fitnessCode))
                    )
                } label: {
                    EmptyView()
                }
                
            }
            .padding(.horizontal)
            .onAppear {
                UITableView.appearance().separatorColor = .clear
                UITableView.appearance().separatorStyle = .none
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            
        }
        
    }
    
    var searchResult:[trainee]{
        if searchText.isEmpty || searchText == ""{
            return trainerUserListViewModel.trainees
        }else{
            return trainerUserListViewModel.trainees.filter{
                $0.username!.contains(searchText)
            }
        }
    }
    
    func DidDissMiss(){
        if self.isChatClicked == true{
            isPresentChat = true
        }
    }
    
}
//MARK: - USERLIST ROW VIEW
struct userListRowView:View{
    @State var item:trainee
    var body: some View{
        HStack{
            URLImageView(urlString: item.userProfile,imageSize: 50, youtube: false)
            
            VStack(alignment:.leading,spacing:5){
                Text(item.username!)
                    .font(.system(.body))
                    .fontWeight(.bold)
                
                Text("회원권 일수가 들어갈 자리입니다.")
                    .foregroundColor(.gray)
                    .font(.caption)
                    .fontWeight(.light)
            }
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity,alignment:.leading)
        .padding(.vertical,10)
    }
}

//MARK: - PREVIEWS
struct TrainerUserListView_Previews: PreviewProvider {
    static var previews: some View {
        TrainerUserListView(baseIndex: .constant(0))
        //        userListRowView(item: trainee(username: "이경민", useremail: "cow970814@naver.com", userid: "asd", userProfile: "asdasd"))
        //            .previewLayout(.sizeThatFits)
    }
}

struct LazyView<Content:View>:View{
    let build: () -> Content
    init(_ build:@autoclosure @escaping ()->Content){
        self.build = build
    }
    
    var body:Content{
        build()
    }
}
