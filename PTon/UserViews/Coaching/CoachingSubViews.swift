//
//  CoachingSubViews.swift
//  PTon
//
//  Created by 이관형 on 2022/02/18.
//

import SwiftUI

struct CoachingFitnessView: View{
    @State var date: String
    @State var trainerId: String

    @State var isAerobic: Bool = true
    @ObservedObject var coachViewModel = CoachViewModel()
    
    init(date: String, trainerId: String)
    {
        self.date = date
        self.trainerId = trainerId
        coachViewModel.getExercise(part: "", date: date, isFitness: true, trainerId: trainerId)
    }
    
    var body: some View{
        ForEach(coachViewModel.savedFitnessList, id: \.self){ item in
            if item.exHydro == "Aerobic"
            {
                CoachingAerobicCell(item: item, level: item.exParameter)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            }
            else
            {
                CoachingAnAerobicCell(item: item, level: item.exParameter)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            }
        }
    }
}


struct CoachingRoutineView: View{
    var body: some View{
        Text("Routine")
    }
}

struct CoachingCompoundView: View{
    
    @State var date: String
    @State var trainerId: String
    @ObservedObject var coachViewModel = CoachViewModel()
    
    
    init(date: String, trainerId: String){
        //1. 복합운동 초기화
        self.date = date
        self.trainerId = trainerId
        coachViewModel.getExercise(part: "Compound", date: date, isFitness: false, trainerId: trainerId)
    }
    
    var body: some View{
        ForEach(coachViewModel.savedCompoundList, id: \.self){ item in
            CoachingAnAerobicCell(item: item, level: item.exParameter)
                .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 10))
        }
    }
}

struct CoachingBackView: View{
    
    @State var date: String
    @State var trainerId: String
    @ObservedObject var coachViewModel = CoachViewModel()
    
    init(date: String, trainerId: String){
        self.date = date
        self.trainerId = trainerId
        coachViewModel.getExercise(part: "Back", date: date, isFitness: false, trainerId: trainerId)
    }
    
    var body: some View{
        ForEach(coachViewModel.savedAnAerobicList, id: \.self){ item in
            CoachingAnAerobicCell(item: item, level: item.exParameter)
                .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 10))
        }
    }
}

struct CoachingChestView: View{
    
    @State var date: String
    @State var trainerId: String
    @ObservedObject var coachViewModel = CoachViewModel()
    
    init(date: String, trainerId: String){
        self.date = date
        self.trainerId = trainerId
        coachViewModel.getExercise(part: "Chest", date: date, isFitness: false, trainerId: trainerId)
    }
    
    var body: some View{
        ForEach(coachViewModel.savedAnAerobicList, id: \.self){ item in
            CoachingAnAerobicCell(item: item, level: item.exParameter)
                .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 10))
        }
    }
}

struct CoachingArmView: View{
    
    @State var date: String
    @State var trainerId: String
    @ObservedObject var coachViewModel = CoachViewModel()
    
    init(date: String, trainerId: String){
        self.date = date
        self.trainerId = trainerId
        coachViewModel.getExercise(part: "Arm", date: date, isFitness: false, trainerId: trainerId)
    }
    
    var body: some View{
        ForEach(coachViewModel.savedAnAerobicList, id: \.self){ item in
            CoachingAnAerobicCell(item: item, level: item.exParameter)
                .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 10))
        }
    }
}

struct CoachingLegView: View{
    
    @State var date: String
    @State var trainerId: String
    @ObservedObject var coachViewModel = CoachViewModel()
    
    init(date: String, trainerId: String){
        self.date = date
        self.trainerId = trainerId
        coachViewModel.getExercise(part: "Leg", date: date, isFitness: false, trainerId: trainerId)
    }
    
    var body: some View{
        ForEach(coachViewModel.savedAnAerobicList, id: \.self){ item in
            CoachingAnAerobicCell(item: item, level: item.exParameter)
                .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 10))
        }
    }
}

struct CoachingAbsView: View{
    
    @State var date: String
    @State var trainerId: String
    @ObservedObject var coachViewModel = CoachViewModel()
    
    init(date: String, trainerId: String){
        self.date = date
        self.trainerId = trainerId
        coachViewModel.getExercise(part: "Leg", date: date, isFitness: false, trainerId: trainerId)
    }
    
    var body: some View{
        ForEach(coachViewModel.savedAnAerobicList, id: \.self){ item in
            CoachingAnAerobicCell(item: item, level: item.exParameter)
                .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 10))
        }
    }
}


struct CoachingAnAerobicCell: View{
    let item: CoachModel
    @State var level: Double
    
    var body: some View
    {
        HStack{
            //1. 운동 사진
            AsyncImage(url: URL(string: item.exUrl), content: { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 100, maxHeight: 60)
            }, placeholder: {
                placeholderImage()
            })
            //2. 운동 내용(이름, 강도 아이콘, 무게, 횟수, 세트수, 소모칼로리)
            VStack
            {
                HStack
                {
                    //2.1 운동 이름
                    Text(String(item.exName))
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 15))
                        .minimumScaleFactor(0.5)
                        .foregroundColor(.black)
                        .frame(width: 120, height: 17, alignment: .leading)
                    
                    //2.2 운동 강도아이콘
                    placeholderColor()
                    

                    Spacer()
                }
//                Spacer()
                //2.3 운동 내용
                HStack
                {
                    Spacer()
                    Spacer()
                    
                    Text(String(item.exWeight) + "Kg").font(.system(size: 12))
                    Spacer()
                    Text(String(item.exTime) + "회").font(.system(size: 12))
                    Spacer()
                    Text(String(item.exSets) + "세트").font(.system(size: 12))
                    Spacer()
                    Spacer()
                    Spacer()
                }
                //2.4 소모 칼로리
                HStack{
                    Text("소모칼로리: 100kcal").font(.system(size: 9))
                    Spacer()
                }
            }
                    
            //3. 완료 버튼
            Button(action: {
                print("Button Clicked")
            }, label: {
                Text("완료").foregroundColor(.white)
            })
                .frame(width: 50, height: 30)
                .background(Color.purple)
                .cornerRadius(25)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60, maxHeight: 60, alignment: .topLeading)
    }
    @ViewBuilder
    func placeholderImage() -> some View
    {
        Image(systemName: "photo")
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 60)
            .foregroundColor(.gray)
    }
    
    @ViewBuilder
    func placeholderColor() -> some View
    {
        if(level < 1.5)
        {
            Text("저강도")
                .font(.system(size: 10))
                .foregroundColor(.white)
                .frame(width: 38, height: 13)
                .background(Color.green)
                .cornerRadius(25)
        }
        else if(level < 2.5 && level > 1.5)
        {
            Text("중강도")
                .font(.system(size: 10))
                .foregroundColor(.white)
                .frame(width: 38, height: 13)
                .background(Color.blue)
                .cornerRadius(25)
        }
        else{
            Text("고강도")
                .font(.system(size: 10))
                .foregroundColor(.white)
                .frame(width: 38, height: 13)
                .background(Color.red)
                .cornerRadius(25)
        }
    }
    
}

struct CoachingAerobicCell: View{
    let item: CoachModel
    @State var level: Double
    
    
    var body: some View
    {
        HStack
        {
            //1. 운동 사진
            AsyncImage(url: URL(string: item.exUrl), content: { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 100, maxHeight: 60)
            }, placeholder: {
                placeholderImage()
            })
            //2. 운동 내용 (이름, 강도 아이콘, 분, 소모칼로리)
            VStack
            {
                //2.1 운동 이름 및 강도 아이콘
                HStack
                {
                    //2.1.1 운동 이름
                    Text(String(item.exName))
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 15))
                        .minimumScaleFactor(0.5)
                        .foregroundColor(.black)
                        .frame(width: 120, height: 17, alignment: .leading)

                    //2.2.2 강도 아이콘
                    placeholderColor()
                    Spacer()
                }

                //2.2 분
                HStack{
                    Spacer()
                    Spacer()
                    Text("추천" + String(item.exMinute) + "분")
                        .font(.system(size: 12))
                    Spacer()
                    Spacer()
                    Spacer()
                }
                //2.3 소모칼로리
                HStack{
                    Text("예상 소모칼로리: 100kcal").font(.system(size: 9))
                    Spacer()
                }
            }
            
            //3. 완료 버튼
            Button(action: {
                print("Button Clicked")
            }, label: {
                Text("완료").foregroundColor(Color.white)
            })
                .frame(width: 50, height: 30)
                .background(Color.purple)
                .cornerRadius(25)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60, maxHeight: 60, alignment: .topLeading)

        
    }
    @ViewBuilder
    func placeholderImage() -> some View
    {
        Image(systemName: "photo")
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 60)
            .foregroundColor(.gray)
    }
    @ViewBuilder
    func placeholderColor() -> some View
    {
        if(level < 1.5)
        {
            Text("저강도")
                .font(.system(size: 10))
                .foregroundColor(.white)
                .frame(width: 38, height: 13)
                .background(Color.green)
                .cornerRadius(25)
        }
        else if(level < 2.5 && level > 1.5)
        {
            Text("중강도")
                .font(.system(size: 10))
                .foregroundColor(.white)
                .frame(width: 38, height: 13)
                .background(Color.blue)
                .cornerRadius(25)
        }
        else{
            Text("고강도")
                .font(.system(size: 10))
                .foregroundColor(.white)
                .frame(width: 38, height: 13)
                .background(Color.red)
                .cornerRadius(25)
        }
    }
}

