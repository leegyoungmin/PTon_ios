////
////  SubExerciseViews.swift
////  Salud0.2
////
////  Created by 이관형 on 2021/12/08.
////
//
//import SwiftUI
//
//struct RequestingFitnessEx: View{
//    @State var date: String
//    @State var userId: String
//    @State var isAerobic: Bool = true
//    @ObservedObject var viewModel = RequestingExerciseViewModel()
//    var body : some View{
//        VStack{
//            List(){
//                ForEach(viewModel.FitnessList, id: \.self){ item in
//                    let model = CommonExerciseListModel(exName: item.exName, exUrl: item.exUrl, parameter: 0.1)
//                    if item.hydro == "Aerobic"{
//                        CommonAerobicListViewCell(item: model, alreadySavedList: self.viewModel.alreadySavedAerobicList, date: $date, userId: $userId, isFitness: true)
//                    }else{
//                        CommonAnAerobicListViewCell(item: model, alreadySavedList: self.viewModel.alreadySavedAnAerobicList, date: $date, userId: $userId,isFitness: true, part: item.hydro)
//
//                    }
//                }
//            }
//        }
//        .onAppear{
//            self.viewModel.getFitnessExerciseList()
//            self.viewModel.getAlreadySavedExercise(part: "Fitness", date: date, userId: userId, isFitness: true)
//        }
//    }
//}
//
//
//struct RequestingRoutineEx: View{
//    @State var date: String
//    @State var userId: String
//    @ObservedObject var viewModel = RequestingExerciseViewModel()
//    var body: some View{
//        Text(date)
//    }
//}
//
////2022.02.17 수정
//struct RequestingCompoundEx: View{
//    @State var date: String
//    @State var userId: String
//    @ObservedObject var viewModel = RequestingExerciseViewModel()
//
//    var body: some View{
//        VStack{
//            if self.viewModel.CommonList.count > 0{
//                List(){
//                    ForEach(viewModel.CommonList, id: \.self){ item in
////                        CommonAerobicListViewCell(item: item, alreadySavedList: self.viewModel.alreadySavedAerobicList, date: $date, userId: $userId)
//                        CommonAnAerobicListViewCell(item: item, alreadySavedList: self.viewModel.alreadySavedAnAerobicList, date: $date, userId: $userId, part: "Compound")
//                    }
//                }
//            }
//        }.onAppear{
//            self.viewModel.getCommonExerciseList(part: "Compound")
//            self.viewModel.getAlreadySavedExercise(part: "Compound", date: date, userId: userId, isFitness: false)
//        }
//    }
//}
//
//struct RequestingBackEx: View{
//    @State var date: String
//    @State var userId: String
//    @ObservedObject var viewModel = RequestingExerciseViewModel()
//    var body: some View{
//        VStack{
//            if self.viewModel.CommonList.count > 0{
//                List(){
//                    ForEach(viewModel.CommonList, id: \.self){ item in
//                        CommonAnAerobicListViewCell(item: item, alreadySavedList: self.viewModel.alreadySavedAnAerobicList, date: $date, userId: $userId, part: "Back")
//                    }
//                }
//            }
//        }.onAppear{
//            self.viewModel.getCommonExerciseList(part: "Back")
//            self.viewModel.getAlreadySavedExercise(part: "Back", date: date, userId: userId, isFitness: false)
//        }
//    }
//}
//
//struct RequestingChestEx: View{
//    @State var date: String
//    @State var userId: String
//    @ObservedObject var viewModel = RequestingExerciseViewModel()
//    var body: some View{
//        VStack{
//            if self.viewModel.CommonList.count > 0{
//                List(){
//                    ForEach(viewModel.CommonList, id: \.self){ item in
//                        CommonAnAerobicListViewCell(item: item, alreadySavedList: self.viewModel.alreadySavedAnAerobicList, date: $date, userId: $userId, part: "Chest")
//                    }
//                }
//            }
//        }.onAppear{
//            self.viewModel.getCommonExerciseList(part: "Chest")
//            self.viewModel.getAlreadySavedExercise(part: "Chest", date: date, userId: userId, isFitness: false)
//        }
//    }
//}
//
//struct RequestingArmEx: View{
//    @State var date: String
//    @State var userId: String
//    @ObservedObject var viewModel = RequestingExerciseViewModel()
//
//    var body: some View{
//        VStack{
//            if self.viewModel.CommonList.count > 0{
//                List(){
//                    ForEach(viewModel.CommonList, id: \.self){ item in
//                        CommonAnAerobicListViewCell(item: item, alreadySavedList: self.viewModel.alreadySavedAnAerobicList, date: $date, userId: $userId, part: "Arm")
//                    }
//                }
//            }
//        }.onAppear{
//            self.viewModel.getCommonExerciseList(part: "Arm")
//            self.viewModel.getAlreadySavedExercise(part: "Arm", date: date, userId: userId, isFitness: false)
//        }
//    }
//}
//
//struct RequestingLegEx: View{
//    @State var date: String
//    @ObservedObject var viewModel = RequestingExerciseViewModel()
//    @State var userId: String
//
//    var body: some View{
//        VStack{
//            if self.viewModel.CommonList.count > 0{
//                List(){
//                    ForEach(viewModel.CommonList, id: \.self){ item in
//                        CommonAnAerobicListViewCell(item: item, alreadySavedList: self.viewModel.alreadySavedAnAerobicList, date: $date, userId: $userId, part: "Leg")
//                    }
//                }
//
//            }
//        }.onAppear{self.viewModel.getCommonExerciseList(part: "Leg")
//            self.viewModel.getAlreadySavedExercise(part: "Leg", date: date, userId: userId, isFitness: false)
//        }
//    }
//}
//
//struct RequestingAbsEx: View{
//    @State var date: String
//    @ObservedObject var viewModel = RequestingExerciseViewModel()
//    @State var userId: String
//
//    var body: some View{
//        VStack{
//            if self.viewModel.CommonList.count > 0{
//                List(){
//                    ForEach(viewModel.CommonList, id: \.self){ item in
//                        CommonAnAerobicListViewCell(item: item, alreadySavedList: self.viewModel.alreadySavedAnAerobicList, date: $date, userId: $userId, part: "Abs")
//                    }
//                }
//            }
//        }.onAppear{
//            self.viewModel.getCommonExerciseList(part: "Abs")
//            self.viewModel.getAlreadySavedExercise(part: "Abs", date: date, userId: userId, isFitness: false)
//        }
//    }
//}
//
//
//struct CommonAerobicListViewCell: View{
//    let item: CommonExerciseListModel
//    let alreadySavedList: [getRequestedAerobicExerciseModel]
//    @Binding var date: String
//    @Binding var userId: String
//    @State var isSaved: Bool = false
//    @State var isFitness: Bool = false
//    @State var minute: Int = 0
//
//    // Alert메세지
//    @State var showingAlert: Bool = false
//    @State var alertText: String = ""
//    // 메시지
//
//    @ObservedObject var viewModel = RequestingExerciseViewModel()
//    @ObservedObject var characterLimit = CharacterLimit()
//
//
//
//    var body: some View{
//        HStack{
//            if #available(iOS 15.0, *){
//                AsyncImage(url: URL(string: item.exUrl), content: { image in
//                    image.resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(maxWidth: 100, maxHeight: 60)
//                }, placeholder: {
//                    placeholderImage()
//                })
//            }else{
//                Image(systemName: "")
//                    .data(url: URL(string: item.exUrl)!)
//                    .resizable()
//                    .frame(maxWidth: 100, maxHeight: 60)
//            }
//            VStack{
//                Text(String(item.exName))
//                    .font(.system(size: 15))
//                    .foregroundColor(.black)
//                Spacer()
//                HStack{
//                    Spacer()
//                    TextField(isSaved ? String(minute) : "", text: $characterLimit.minute)
//                        .background(isSaved ? Color.white : Color.gray)
//                        .cornerRadius(25)
//                        .keyboardType(.numberPad)
//                        .multilineTextAlignment(.center)
//                        .lineLimit(1)
//                        .foregroundColor(Color.black)
//                        .disabled(isSaved)
//                        .frame(width:50)
//                    Text("분")
//                        .font(.system(size: 12))
//                    Spacer()
//                }
//            }
//            Spacer()
//            Button(action: {
//                if characterLimit.minute.count == 0{
//                    showingAlert = true
//                    alertText = "시간을 입력해주세요."
//                }else{
//                    if isFitness{
//                        viewModel.setFitnessAerobicExerciseitem(
//                            item: item,
//                            date: date,
//                            userId: userId,
//                            minute: characterLimit.minute)
//                        isSaved = true
//                        minute = Int(characterLimit.minute)!
//                    }else{
//                        viewModel.setCommonAerobicExerciseItem(
//                            item: item,
//                            date: date,
//                            userId: userId,
//                            minute: characterLimit.minute)
//                        isSaved = true
//                        minute = Int(characterLimit.minute) ?? 5
//                    }
//                }
//
//
//            }){
//                Text(isSaved ? "완료" : "담기")
//                    .font(.system(size: 20))
//                    .foregroundColor(isSaved ? .white : .black)
//                    .disabled(isSaved)
//            }
//            .alert(isPresented: $showingAlert){
//                Alert(title: Text("전송 오류"), message: Text(alertText), dismissButton: .cancel())
//            }
//            .frame(width: 50, height: 40)
//            .buttonStyle(PlainButtonStyle())
//            .background(Color.purple)
//            .cornerRadius(25)
//        }.onAppear{
//            for alreadyItem in alreadySavedList {
//                print("AlreadyItem:::\(alreadyItem)")
//                if alreadyItem.exName == item.exName{
//                    isSaved = true
//                    minute = alreadyItem.exMinute
//                }
//            }
//        }
//    }
//    @ViewBuilder
//    func placeholderImage() -> some View {
//        Image(systemName: "photo")
//            .renderingMode(.template)
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .frame(width: 100, height: 60)
//            .foregroundColor(.gray)
//    }
//}
//
//
//
//struct CommonAnAerobicListViewCell: View{
//    let item: CommonExerciseListModel
//    let alreadySavedList: [getRequestedAnAerobicExerciseModel]
//    @Binding var date: String
//    @Binding var userId: String
//    @State var isSaved: Bool = false
//    @State var isFitness: Bool = false
//    @State var weight: Int = 0
//    @State var sets: Int = 0
//    @State var times: Int = 0
//
//    // Alert메세지
//    @State var showingAlert: Bool = false
//    @State var alertText: String = ""
//    // 메시지
//
//    @State var part: String
//    @ObservedObject var viewModel = RequestingExerciseViewModel()
//    @ObservedObject var characterLimit = CharacterLimit()
//
//
//
//    var body: some View{
//        HStack{
//            if #available(iOS 15.0, *){
//                AsyncImage(url: URL(string: item.exUrl), content: { image in
//                    image.resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(maxWidth: 100, maxHeight: 60)
//                }, placeholder: {
//                    placeholderImage()
//                })
//            }else{
//                Image(systemName: "")
//                    .data(url: URL(string: item.exUrl)!)
//                    .resizable()
//                    .frame(maxWidth: 100, maxHeight: 60)
//            }
//            VStack{
//                Text(String(item.exName))
//                    .font(.system(size: 15))
//                    .foregroundColor(.black)
//                Spacer()
//                HStack{
//                    TextField(isSaved ? String(weight) : "", text: $characterLimit.weight)
//                        .background(isSaved ? Color.white : Color.gray)
//                        .cornerRadius(25)
//                        .keyboardType(.numberPad)
//                        .multilineTextAlignment(.center)
//                        .lineLimit(1)
//                        .foregroundColor(Color.black)
//                        .disabled(isSaved)
//                    Text("Kg")
//                        .font(.system(size: 12))
//                    Spacer()
//                    TextField(isSaved ? String(times) : "", text: $characterLimit.time)
//                        .background(isSaved ? Color.white : Color.gray)
//                        .cornerRadius(25)
//                        .keyboardType(.numberPad)
//                        .multilineTextAlignment(.center)
//                        .lineLimit(1)
//                        .foregroundColor(Color.black)
//                        .disabled(isSaved)
//
//                    Text("회")
//                        .font(.system(size: 12))
//                    Spacer()
//                    TextField(isSaved ? String(sets) : "", text: $characterLimit.sets)
//                        .background(isSaved ? Color.white : Color.gray)
//                        .cornerRadius(25)
//                        .keyboardType(.numberPad)
//                        .multilineTextAlignment(.center)
//                        .lineLimit(1)
//                        .foregroundColor(Color.black)
//                        .disabled(isSaved)
//
//                    Text("세트")
//                        .font(.system(size: 12))
//                }
//            }
//            Spacer()
//
//            Button(action: {
//                if characterLimit.weight.count == 0{
//                    showingAlert = true
//                    if characterLimit.time.count == 0 && characterLimit.sets.count == 0{
//                        alertText = "무게,횟수,세트수를 입력해주세요."
//                    }
//                    else if characterLimit.time.count != 0 && characterLimit.sets.count == 0{
//                        alertText = "무게, 세트수를 입력해주세요."
//                    }
//                    else if characterLimit.time.count == 0 && characterLimit.sets.count != 0{
//                        alertText = "무게, 횟수를 입력해주세요."
//                    }
//                    else if characterLimit.time.count != 0 && characterLimit.sets.count != 0{
//                        alertText = "무게를 입력해주세요."
//                    }
//                }else if characterLimit.weight.count != 0{
//                    if characterLimit.time.count == 0 && characterLimit.sets.count == 0{
//                        showingAlert = true
//                        alertText = "횟수, 세트수를 입력해주세요."
//                    }
//                    else if characterLimit.time.count != 0 && characterLimit.sets.count == 0{
//                        showingAlert = true
//                        alertText = "세트수를 입력해주세요."
//                    }
//                    else if characterLimit.time.count == 0 && characterLimit.sets.count != 0{
//                        showingAlert = true
//                        alertText = "횟수를 입력해주세요."
//                    }
//                    else if characterLimit.time.count != 0 && characterLimit.sets.count != 0{
//                        showingAlert = false
//                        if isFitness{
//                                viewModel.setFitnessAnAerobicExerciseItem(
//                                    weight: characterLimit.weight,
//                                    time: characterLimit.time,
//                                    set: characterLimit.sets,
//                                    item: item,
//                                    date: date,
//                                    userId: userId)
//                                isSaved = true
//                                weight = Int(characterLimit.weight)!
//                                sets = Int(characterLimit.sets)!
//                                times = Int(characterLimit.time)!
//
//                        }else{
//                            viewModel.setCommonAnAerobicExeciseItem(
//                                weight: characterLimit.weight,
//                                time: characterLimit.time,
//                                set: characterLimit.sets,
//                                item: item,
//                                part: part,
//                                date: date,
//                                userId: userId)
//                            isSaved = true
//                            weight = Int(characterLimit.weight)!
//                            sets = Int(characterLimit.sets)!
//                            times = Int(characterLimit.time)!
//                        }
//                    }
//                }
//            }){
//
//                Text(isSaved ? "완료" : "담기")
//                    .font(.system(size: 20))
//                    .foregroundColor(isSaved ? .white : .black)
//                    .disabled(isSaved)
//            }
//            .alert(isPresented: $showingAlert){
//                Alert(title: Text("전송 오류"), message: Text(alertText), dismissButton: .cancel())
//            }
//            .frame(width: 50, height: 40)
//            .buttonStyle(PlainButtonStyle())
//            .background(Color.purple)
//            .cornerRadius(25)
//        }.onAppear{
//            for alreadyItem in alreadySavedList {
//                if alreadyItem.exName == item.exName{
//                    isSaved = true
//                    weight = alreadyItem.exWeight
//                    times = alreadyItem.exTime
//                    sets = alreadyItem.exSets
//                }
//            }
//        }
//    }
//    @ViewBuilder
//    func placeholderImage() -> some View {
//        Image(systemName: "photo")
//            .renderingMode(.template)
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .frame(width: 100, height: 60)
//            .foregroundColor(.gray)
//    }
//}
//
//
//
//
//class CharacterLimit: ObservableObject{
//    var limit: Int = 2
//
//    @Published var weight: String = ""{
//        didSet{
//            if weight.count > limit{
//                weight = String(weight.prefix(limit))
//            }
//        }
//    }
//
//
//    @Published var time: String = ""{
//        didSet{
//            if time.count > limit{
//                time = String(time.prefix(limit))
//            }
//        }
//    }
//
//    @Published var sets: String = ""{
//        didSet{
//            if sets.count > limit{
//                sets = String(sets.prefix(limit))
//            }
//        }
//    }
//
//    @Published var minute: String = ""{
//        didSet{
//            if minute.count > limit{
//                minute = String(minute.prefix(limit))
//            }
//        }
//    }
//}
//
