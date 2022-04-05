//
//  ProfileView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/09.
//

import SwiftUI
//import BottomSheet

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    let grids = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    let icons = geticons()
    @StateObject var viewmodel:ProfileViewModel
    @State var offset = CGSize.zero
    @Binding var ispresent:Bool
    @Binding var isChatting:Bool
    @State var isPresentBottomSheet:Bool = false
    @State var memberShipType:membershipType?
    @Binding var index:Int
    let trainerName:String
    var body: some View {
        
        //TODO: - 제스처에 따른 화면 offset 변경
        let dragGesture = DragGesture()
            .onChanged { value in
                if value.predictedEndLocation.y - value.startLocation.y > 30{
                    withAnimation {
                        offset = value.translation
                    }
                }
                
            }
            .onEnded {
                if $0.translation.height > -30{
                    withAnimation {
                        offset = .zero
                        self.isChatting = false
                        self.ispresent = false
                        dismiss.callAsFunction()
                    }
                }else{
                    offset = .zero
                }
            }
        
        NavigationView{
            ZStack{
                Color("Background")
                    .edgesIgnoringSafeArea(.all)
                VStack{
                    HStack{
                        Button {
                            self.isChatting = false
                            self.ispresent = false
                            dismiss.callAsFunction()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 23))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                    }
                    .padding()
                    
                    Spacer()
                }
                
                VStack(spacing:50){
                    
                    
                    VStack(spacing:20){
                        URLImageView(urlString: viewmodel.trainee.userProfile, imageSize: 200, youtube: false)
                        
                        Text(viewmodel.trainee.userName).font(.system(size: 25)).fontWeight(.semibold)+Text(" 회원님")
                            .font(.system(size: 25))
                            .fontWeight(.light)
                        
                        HStack{
                            if viewmodel.MemberShip.startMember == nil || viewmodel.MemberShip.endMember == nil || (convertInteval(firstDate:viewmodel.MemberShip.endMember!,second:viewmodel.MemberShip.startMember!) == 0){
                                Button {
                                    self.memberShipType = .date
                                    self.isPresentBottomSheet = true
                                } label: {
                                    Text("회원권")
                                        .foregroundColor(.white)
                                        .bold()
                                }
                                .buttonStyle(MemberShipButtonStyle(isText: false))
                            }else{
                                Button {
                                } label: {
                                    Text("D - \(convertInteval(firstDate:viewmodel.MemberShip.endMember!,second:viewmodel.MemberShip.startMember!))")
                                        .foregroundColor(Color.accentColor)
                                        .bold()
                                }
                                .buttonStyle(MemberShipButtonStyle(isText: true))
                                
                            }
                            
                            if viewmodel.MemberShip.maxLisence == nil || viewmodel.MemberShip.useLisence == nil || (viewmodel.MemberShip.IntMaxLisense - viewmodel.MemberShip.IntuserLisence) <= 0{
                                Button {
                                    self.memberShipType = .lisence
                                    self.isPresentBottomSheet = true
                                } label: {
                                    Text("PT권")
                                        .foregroundColor(.white)
                                        .bold()
                                }
                                .buttonStyle(MemberShipButtonStyle(isText: false))
                                
                            }
                            else{
                                Button {
                                } label: {
                                    Text("\(viewmodel.MemberShip.useLisence!)회 / \(viewmodel.MemberShip.maxLisence!)회")
                                        .foregroundColor(.accentColor)
                                        .bold()
                                }
                                .buttonStyle(MemberShipButtonStyle(isText: true))
                            }
                        }
                        
                    }
                    
                    LazyVGrid(columns: grids, alignment: .center){
                        
                        Button {
                            self.index = 1
                            self.isChatting = true
                            dismiss()
                        } label: {
                            ProfileButton(icons[0])
                        }
                        
                        NavigationLink {
                            TrainerJournalView(viewModel: TrainerJournalViewModel(trainerId: viewmodel.traineid,
                                                                                  userId: viewmodel.trainee.userId)
                                               ,userName: viewmodel.trainee.userName)
                        } label: {
                            ProfileButton(icons[1])
                        }
                        
                        NavigationLink {
                            StretchingRequestView(stretchingViewModel: StretchingViewModel(trainerid: viewmodel.traineid, userid:viewmodel.trainee.userId))
                        } label: {
                            ProfileButton(icons[2])
                        }
                        NavigationLink {
                            SurveyView(surveyViewModel: SurveyViewModel(viewmodel.traineid, viewmodel.trainee.userId))
                        } label: {
                            ProfileButton(icons[3])
                        }
                        NavigationLink {
                            MemoListView(viewmodel: MemoListViewModel(trainerid: viewmodel.traineid, userid: viewmodel.trainee.userId, userProfile: viewmodel.trainee.userProfile ?? ""),
                                         userName: viewmodel.trainee.userName,
                                         trainerId: viewmodel.traineid,
                                         trainerName: self.trainerName)
                            .navigationTitle("")
                            .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            ProfileButton(icons[4])
                        }
                        NavigationLink {
                            RequestedExerciseView(
                                viewmodel: RequestedExerciseViewModel(viewmodel.trainee.userId),
                                fitnessCode: viewmodel.fitnessCode)
                            
                        } label: {
                            ProfileButton(icons[5])
                        }
                        
                    }
                    .padding(.vertical,20)
                    .buttonStyle(.plain)
                    .background(.white)
                    .cornerRadius(5)
                    
                    
                }
                .padding()
                
            }
            .gesture(dragGesture)
            .offset(y: offset.height)
            .navigationTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            //            .bottomSheet(isPresented: $isPresentBottomSheet,detents: [.medium()],isModalInPresentation: true) {
            //                if self.memberShipType != nil{
            //
            //                    MemberShipSettingView(isPresented: $isPresentBottomSheet,
            //                                          type: self.memberShipType!)
            //                        .environmentObject(self.viewmodel)
            //                }
            //            }
        }
        //TODO: - chatting room navigation
        
    }
    
    func TappedChatting(completion:@escaping(String?)->Void){
        self.ispresent = false
        self.isChatting = true
        completion(viewmodel.trainee.userId)
    }
    
    func ProfileButton(_ icon:icon) -> some View{
        VStack(spacing:10){
            Image(systemName: icon.iconImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30, alignment: .center)
                .padding()
                .background(Color("Background"))
                .cornerRadius(5)
            
            Text(icon.iconName)
                .fontWeight(.light)
        }
        .padding(10)
    }
}

enum membershipType{
    case date,lisence
}

struct MemberShipSettingView:View{
    @EnvironmentObject var viewmodel:ProfileViewModel
    @Binding var isPresented:Bool
    let type:membershipType
    var body: some View{
        VStack{
            
            HStack{
                Button {
                    self.isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 30))
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            .padding(.top)
            
            switch type {
            case .date:
                DateSettingView(isPresented: $isPresented)
                    .padding()
            case .lisence:
                LisenceSettingView(isPresented: $isPresented)
                    .environmentObject(self.viewmodel)
            }
        }
        .padding(.horizontal)
        
    }
}

struct LisenceSettingView:View{
    @EnvironmentObject var viewmodel:ProfileViewModel
    @Binding var isPresented:Bool
    @State var maxCount:Int = 0
    @State var useCount:Int = 0
    var body: some View{
        VStack{
            Spacer()
            
            GroupBox {
                Stepper("\(maxCount) 회", value: $maxCount,in: 0...100)
            } label: {
                Text("전체 횟수")
            }
            
            GroupBox {
                Stepper("\(useCount) 회", value: $useCount,in: 0...maxCount)
            } label: {
                Text("차감 횟수")
            }
            .background(.clear)
            
            Spacer()
            
            Button {
                let data = [
                    "ptTimes":String(maxCount),
                    "ptUsed":String(useCount)
                ]
                viewmodel.setLisenceData(data)
                self.isPresented = false
            } label: {
                Text("저장하기")
                    .foregroundColor(.white)
            }
            .buttonStyle(MemberShipButtonStyle(isText: false))
            .padding(.top,20)
            
            Spacer()
        }
    }
}

struct DateSettingView:View{
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewmodel:ProfileViewModel
    @State var startDate = Date()
    @State var endDate = Date()
    @Binding var isPresented:Bool
    var body: some View{
        VStack{
            Spacer()
            
            DatePicker("시작 날짜", selection: $startDate,displayedComponents: .date)
            
            DatePicker("종료 날짜", selection: $endDate, in: startDate...,displayedComponents: .date)
            
            Spacer()
            
            Button {
                let data = [
                    "StartDate":convertString(content: startDate, dateFormat: "yyyy-MM-dd"),
                    "EndDate":convertString(content: endDate, dateFormat: "yyyy-MM-dd")
                ]
                viewmodel.setDateData(data)
                withAnimation {
                    self.dismiss.callAsFunction()
                }
                
            } label: {
                Text("저장하기")
                    .foregroundColor(.white)
            }
            .buttonStyle(MemberShipButtonStyle(isText: false))
            .padding(.top,20)
            
            Spacer()
            
        }
        .datePickerStyle(.compact)
        .environment(\.locale, Locale(identifier: "ko_KR"))
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}

struct MemberShipButtonStyle:ButtonStyle{
    let isText:Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth:80)
            .buttonStyle(.plain)
            .padding(.horizontal,20)
            .padding()
            .background(isText ? .clear:Color.accentColor)
            .cornerRadius(5)
            .overlay(
                RoundedCorner(radius: 5)
                    .stroke(isText ? Color.accentColor:.clear)
                    .foregroundColor(isText ? .white:Color.accentColor)
            )
            .allowsHitTesting(isText ? false:true)
    }
}

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView(viewmodel: ProfileViewModel("", "", trainee()), ispresent: .constant(true), isChatting: .constant(false), index: .constant(1), trainerName: "이경민")
//        //        Group{
//        //            Button {
//        //                print("Action 회원권 버튼")
//        //            } label: {
//        //                Text("회원권")
//        //                    .foregroundColor(Color.accentColor)
//        //                    .bold()
//        //            }
//        //            .buttonStyle(MemberShipButtonStyle(isText: true))
//        //
//        //
//        //
//        //            Text("123123")
//        //                .padding(.horizontal,5)
//        //                .padding()
//        //                .frame(minWidth:80)
//        //                .background(.purple)
//        //
//        //        }
//        //        .previewLayout(.sizeThatFits)
//        //        .padding()
//        //
//        //        Group{
//        //            MemberShipSettingView(isPresented: .constant(true), type: .date)
//        //        }
//        //        .previewLayout(.fixed(width: UIScreen.main.bounds.width, height: 300))
//        //        .padding()
//    }
//    
//    
//}

