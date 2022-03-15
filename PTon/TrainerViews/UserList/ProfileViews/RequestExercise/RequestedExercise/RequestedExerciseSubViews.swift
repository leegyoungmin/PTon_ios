////
////  RequestedSubExericseViews.swift
////  Salud0.2
////
////  Created by 이관형 on 2022/01/23.
////
//
//import SwiftUI
//
//struct RequestedFitnessEx: View{
//    @State var date: String
//    @State var userId: String
//    @State var isAerobic: Bool = true
//    @ObservedObject var requestedViewModel = RequestedExerciseViewModel()
//
//    init(date: String, userId: String){
//        self.date = date
//        self.userId = userId
//
//        self.requestedViewModel.getAlreadySavedFitnessExercise(date: date, userId: userId)
//
//    }
//
//    var body: some View{
//        VStack{
//            List(){
//                ForEach(requestedViewModel.alreadySavedFitnessList, id: \.self){ item in
//
//
//                    if item.exHydro == "Aerobic"{
//                        let model = getRequestedAerobicExerciseModel(
//                            exName: item.exName,
//                            exMinute: item.exMinute,
//                            exDone: item.exDone,
//                            exUrl: item.exUrl,
//                            exParameter: item.exParameter)
//                        RequestedAerobicListViewCell(item: model, Fitness: true, date: $date, userId: $userId)
//                    }
//                    else{
//                        let model = getRequestedAnAerobicExerciseModel(
//                            exName: item.exName,
//                            exSets: item.exSets,
//                            exTime: item.exTime,
//                            exWeight: item.exWeight,
//                            exDone: item.exDone,
//                            exUrl: item.exUrl,
//                            exMinute: item.exMinute,
//                            exParameter: item.exParameter)
//                        RequestedAnAerobicListViewCell(
//                            item: model,
//                            Fitness: true,
//                            part: "Anaerobic",
//                            date: $date,
//                            userId: $userId)
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct RequestedRoutineEx: View{
//    @State var date: String
//    @State var userId: String
//    var body: some View{
//        Text(date)
//    }
//}
//
//struct RequestedAerobicEx: View{
//    @State var date: String
//    @State var userId: String
//    @ObservedObject var viewModel = RequestingExerciseViewModel()
//
//    init(date: String, userId: String){
//        self.date = date
//        self.userId = userId
//
//        self.viewModel.getAlreadySavedExercise(part: "Aerobic", date: date, userId: userId, isFitness: false)
//    }
//    var body: some View{
//        VStack{
//            if self.viewModel.alreadySavedAerobicList.count > 0{
//                List(){
//                    ForEach(viewModel.alreadySavedAerobicList, id: \.self.id){ item in
//                        RequestedAerobicListViewCell(item: item, date: $date, userId: $userId)
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct RequestedBackEx: View{
//    @State var date: String
//    @State var userId: String
//    @ObservedObject var viewModel = RequestingExerciseViewModel()
//
//    init(date: String, userId: String){
//        self.date = date
//        self.userId = userId
//
//        self.viewModel.getAlreadySavedExercise(part: "Back", date: date, userId: userId, isFitness: false)
//    }
//
//    var body: some View{
//        VStack{
//            if self.viewModel.alreadySavedAnAerobicList.count > 0{
//                List(){
//                    ForEach(viewModel.alreadySavedAnAerobicList, id: \.self.id){ item in
//                        RequestedAnAerobicListViewCell(item: item, part: "Back", date: $date, userId: $userId)
//                    }
//                }
//            }
//
//        }
//    }
//}
//
//struct RequestedChestEx: View{
//    @State var date: String
//    @State var userId: String
//    @ObservedObject var viewModel = RequestingExerciseViewModel()
//
//    init(date: String, userId: String){
//        self.date = date
//        self.userId = userId
//
//        self.viewModel.getAlreadySavedExercise(part: "Chest", date: date, userId: userId, isFitness: false)
//    }
//
//    var body: some View{
//        VStack{
//            if self.viewModel.alreadySavedAnAerobicList.count > 0{
//                List(){
//                    ForEach(viewModel.alreadySavedAnAerobicList, id: \.self.id){ item in
//                        RequestedAnAerobicListViewCell(item: item, part: "Chest", date: $date, userId: $userId)
//                    }
//                }
//            }
//
//        }
//    }
//}
//
//struct RequestedArmEx: View{
//    @State var date: String
//    @State var userId: String
//    @ObservedObject var viewModel = RequestingExerciseViewModel()
//
//    init(date: String, userId: String){
//        self.date = date
//        self.userId = userId
//
//        self.viewModel.getAlreadySavedExercise(part: "Arm", date: date, userId: userId, isFitness: false)
//    }
//
//    var body: some View{
//        VStack{
//            if self.viewModel.alreadySavedAnAerobicList.count > 0{
//                List(){
//                    ForEach(viewModel.alreadySavedAnAerobicList, id: \.self.id){ item in
//                        RequestedAnAerobicListViewCell(item: item, part: "Arm", date: $date, userId: $userId)
//                    }
//                }
//            }
//
//        }
//    }
//}
//
//struct RequestedLegEx: View{
//    @State var date: String
//    @State var userId: String
//    @ObservedObject var viewModel = RequestingExerciseViewModel()
//
//    init(date: String, userId: String){
//        self.date = date
//        self.userId = userId
//
//        self.viewModel.getAlreadySavedExercise(part: "Leg", date: date, userId: userId, isFitness: false)
//    }
//
//    var body: some View{
//        VStack{
//            if self.viewModel.alreadySavedAnAerobicList.count > 0{
//                List(){
//                    ForEach(viewModel.alreadySavedAnAerobicList, id: \.self.id){ item in
//                        RequestedAnAerobicListViewCell(item: item, part: "Leg", date: $date, userId: $userId)
//                    }
//                }
//            }
//
//        }
//    }
//}
//
//struct RequestedAbsEx: View{
//    @State var date: String
//    @State var userId: String
//    @ObservedObject var viewModel = RequestingExerciseViewModel()
//
//    init(date: String, userId: String){
//        self.date = date
//        self.userId = userId
//
//        self.viewModel.getAlreadySavedExercise(part: "Abs", date: date, userId: userId, isFitness: false)
//    }
//
//    var body: some View{
//        VStack{
//            if self.viewModel.alreadySavedAnAerobicList.count > 0{
//                List(){
//                    ForEach(viewModel.alreadySavedAnAerobicList, id: \.self.id){ item in
//                        RequestedAnAerobicListViewCell(item: item, part: "Abs", date: $date, userId: $userId)
//                    }
//                }
//            }
//
//        }
//    }
//}
//
//
//struct RequestedAerobicListViewCell: View{
//    let item: getRequestedAerobicExerciseModel
//    @State var Fitness: Bool = false
//    @Binding var date: String
//    @Binding var userId: String
//
//    @ObservedObject var viewModel = RequestingExerciseViewModel()
//    @ObservedObject var requestedViewModel = RequestedExerciseViewModel()
//    @ObservedObject var characterLimit = CharacterLimit()
//
//
//    var body: some View{
//        HStack{
//            AsyncImage(url: URL(string: item.exUrl), content: { image in
//                image.resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(maxWidth: 100, maxHeight: 60)
//            }, placeholder: {
//                placeholderImage()
//            })
//            VStack{
//                Text(String(item.exName))
//                    .font(.system(size: 15))
//                    .foregroundColor(.black)
//                Spacer()
//                HStack{
//                    Spacer()
//                    TextField(String(item.exMinute), text: $characterLimit.minute)
//                        .background(Color.white)
//                        .cornerRadius(25)
//                        .keyboardType(.numberPad)
//                        .multilineTextAlignment(.center)
//                        .lineLimit(1)
//                        .foregroundColor(Color.black)
//                        .frame(width: 50)
//                        .onAppear{
//                            characterLimit.minute = String(item.exMinute)
//                        }
//                    Text("분")
//                        .font(.system(size: 12))
//                    Spacer()
//                    VStack{
//                        Button(action: {
//                            if Fitness{
//                                let model = alreadySavedFitnessModel(
//                                    exName: item.exName,
//                                    exUrl: item.exUrl,
//                                    exDone: item.exDone,
//                                    exParameter: item.exParameter,
//                                    exMinute: Int(characterLimit.minute) ?? item.exMinute,
//                                    exTime: 0,
//                                    exWeight: 0,
//                                    exSets: 0,
//                                    exHydro: "Aerobic")
//
//                                requestedViewModel.setModifiedFitnessExerciseItem(hydro: "Aerobic", item: model, date: date, userId: userId)
//                            }else{
//                                requestedViewModel.setModifiedAerobicExerciseItem(
//                                    minute: characterLimit.minute,
//                                    item: item,
//                                    date: date,
//                                    userId: userId)
//                            }
//
//                        }){
//                            Text("수정")
//                                .font(.system(size: 20))
//                                .foregroundColor(.white)
//                        }
//                        .buttonStyle(.borderless)
//                        .background(Color.purple)
//                        Spacer()
//                        Button(action: {
//                            if Fitness{
//                                print("Fitness Checked")
//
//                                requestedViewModel.setDeleteExerciseItem(
//                                    part: "Aerobic",
//                                    exName: item.exName,
//                                    date: date,
//                                    userId: userId,
//                                    isFitness: true)
//                            }else{
//                                requestedViewModel.setDeleteExerciseItem(
//                                    part: "Aerobic",
//                                    exName: item.exName,
//                                    date: date,
//                                    userId: userId,
//                                    isFitness: false)
//                            }
//
//                        }){
//                            Text("삭제")
//                                .font(.system(size: 20))
//                                .foregroundColor(.white)
//                        }
//                        .buttonStyle(.borderless)
//                        .background(Color.purple)
//                    }
//
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
//struct RequestedAnAerobicListViewCell: View{
//    let item: getRequestedAnAerobicExerciseModel
//    @State var Fitness: Bool = false
//    @State var part: String
//    @Binding var date: String
//    @Binding var userId: String
//
//
//    @ObservedObject var viewModel = RequestingExerciseViewModel()
//    @ObservedObject var requestedViewModel = RequestedExerciseViewModel()
//    @ObservedObject var characterLimit = CharacterLimit()
//
//    var body: some View{
//        HStack{
//            AsyncImage(url: URL(string: item.exUrl), content: { image in
//                image.resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(maxWidth: 100, maxHeight: 60)
//            }, placeholder: {
//                placeholderImage()
//            })
//            VStack{
//                Text(String(item.exName))
//                    .font(.system(size: 15))
//                    .foregroundColor(.black)
//                Spacer()
//                HStack{
//                    TextField(String(item.exWeight), text: $characterLimit.weight)
//                        .background(Color.white)
//                        .cornerRadius(25)
//                        .keyboardType(.numberPad)
//                        .multilineTextAlignment(.center)
//                        .lineLimit(1)
//                        .foregroundColor(Color.black)
//                        .onAppear{
//                            characterLimit.weight = String(item.exWeight)
//                        }
//                    Text("Kg")
//                        .font(.system(size: 12))
//                    Spacer()
//                    TextField(String(item.exTime), text: $characterLimit.time)
//                        .background(Color.white)
//                        .cornerRadius(25)
//                        .keyboardType(.numberPad)
//                        .multilineTextAlignment(.center)
//                        .lineLimit(1)
//                        .foregroundColor(Color.black)
//                        .onAppear{
//                            characterLimit.time = String(item.exTime)
//                        }
//                    Text("회")
//                        .font(.system(size: 12))
//                    Spacer()
//                    TextField(String(item.exSets), text: $characterLimit.sets)
//                        .background(Color.white)
//                        .cornerRadius(25)
//                        .keyboardType(.numberPad)
//                        .multilineTextAlignment(.center)
//                        .lineLimit(1)
//                        .foregroundColor(Color.black)
//                        .onAppear{
//                            characterLimit.sets = String(item.exSets)
//                        }
//                    Text("세트")
//                        .font(.system(size: 12))
//                }
//            }
//            Spacer()
//            VStack{
//                Button(action: {
//                    print("Modifying")
//                    if Fitness{
//                        let model = alreadySavedFitnessModel(
//                            exName: item.exName,
//                            exUrl: item.exUrl,
//                            exDone: item.exDone,
//                            exParameter: item.exParameter,
//                            exMinute: item.exMinute,
//                            exTime: Int(characterLimit.time) ?? 0,
//                            exWeight: Int(characterLimit.weight) ?? 0,
//                            exSets: Int(characterLimit.sets) ?? 0,
//                            exHydro: "Anaerobic")
//
//
//                        requestedViewModel.setModifiedFitnessExerciseItem(
//                            hydro: "Anaerobic",
//                            item: model,
//                            date: date,
//                            userId: userId)
//                    }else{
//                        requestedViewModel.setModifiedAnAerobicExerciseItem(
//                            part: part,
//                            weight: characterLimit.weight,
//                            time: characterLimit.time,
//                            set: characterLimit.sets,
//                            item: item,
//                            date: date,
//                            userId: userId)
//                    }
//
//                }){
//                    Text("수정")
//                        .font(.system(size: 20))
//                        .foregroundColor(.white)
//                }
//                .buttonStyle(.borderless)
//                .background(Color.purple)
//                Spacer()
//                Button(action: {
//                    print("Delete")
//                    if Fitness{
//                        requestedViewModel.setDeleteExerciseItem(part: part, exName: item.exName, date: date, userId: userId, isFitness: true)
//                    }else{
//                        requestedViewModel.setDeleteExerciseItem(part: part, exName: item.exName, date: date, userId: userId, isFitness: false)
//                    }
//
//
//                }){
//                    Text("삭제")
//                        .font(.system(size: 20))
//                        .foregroundColor(.white)
//                }
//                .buttonStyle(.borderless)
//                .background(Color.purple)
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
