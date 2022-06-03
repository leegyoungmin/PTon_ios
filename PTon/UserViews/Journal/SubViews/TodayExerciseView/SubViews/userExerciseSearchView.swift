//
//  userExerciseSearchView.swift
//  PTon
//
//  Created by 이경민 on 2022/05/29.
//

import SwiftUI
import InstantSearchCore
import InstantSearchSwiftUI
import Kingfisher

struct userExerciseSearchView: View {
    @ObservedObject var hitsController:HitsObservableController<exerciseResult>
    @ObservedObject var queryController:SearchBoxObservableController
    @ObservedObject var facetListController: FacetListObservableController
    @EnvironmentObject var viewModel:userExerciseSearchViewModel
    
    //MARK: - VIEW PROPERTIES
    @Namespace private var namespace
    @State var selectedExercise:exerciseResult?
    @State var isEditing:Bool = false
    @State var isPresentSheet:Bool = false
    @State var isPresentRecord:Bool = false
    
    
    //MARK: - FUNCTIONS
    private func checkStrength(_ raw:Double)->Color{
        switch raw{
        case 0...2.5:
            return Color.green
        case 2.5...3.5:
            return Color.yellow
        case 3.5...:
            return Color.red
        default:
            return Color.green
        }
    }
    
    var searchBar:some View{
        HStack (spacing:10){
            
            if !isEditing{
                Button {
                    withAnimation {
                        isPresentSheet.toggle()
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
            
            HStack{
                TextField("운동을 검색해보세요.", text: $queryController.query,onEditingChanged: { isEditing in
                    
                },onCommit: {
                    queryController.submit()
                })
                .font(.system(size: 15))
                
                if isEditing{
                    Button {
                        queryController.submit()
                        UIApplication.shared.endEditing()
                        print(123)
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }
                
            }
            
        }
        .padding(.horizontal)
        .padding(.vertical,10)
        .background(backgroundColor)
        .cornerRadius(10)
    }
    
    var body: some View {
        ZStack{
            //1. 검색 뷰
            VStack {
                //검색 결과 뷰
                searchBar
                    .disabled(isPresentSheet || isPresentRecord)
                
                HitsList(hitsController) { hit, _ in
                    if hit != nil{
                        HStack(alignment: .center){
                            VStack{


                                CustomContextMenu {
                                    
                                    if hit!.url == "default"{
                                        Image("defaultImage")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60, alignment: .center)
                                            .cornerRadius(20)
                                            .clipped()
                                            .shadow(color: .gray, radius: 1, x: 0, y: 0)
                                    }else{
                                        KFImage(URL(string: hit!.url))
                                            .onFailureImage(KFCrossPlatformImage(named: "defaultImage"))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60, alignment: .center)
                                            .cornerRadius(20)
                                            .clipped()
                                            .shadow(color: .gray, radius: 1, x: 0, y: 0)
                                    }
                                    
                                    
                                } preview: {
                                    KFImage(URL(string: hit?.url ?? ""))
                                        .onFailureImage(KFCrossPlatformImage(named: "defaultImage"))
                                        .resizable()
                                        .scaledToFit()
                                        .onAppear {
                                            print("User weight setting value ::: \(viewModel.userWeight)")
                                        }
                                } actions: {
                                    return UIMenu()
                                } onEnded: {
                                }
                            }

                            VStack(alignment: .leading,spacing: 0){
                                HStack(spacing:5){
                                    Text(hit!.exerciseName)
                                        .font(.title3)
                                        .fontWeight(.heavy)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)


                                    Circle()
                                        .fill(checkStrength(hit!.parameter))
                                        .frame(width: 10, height: 10, alignment: .center)

                                }
                                HStack(spacing:5){
                                    Text(hit!.engName)
                                        .font(.footnote)
                                        .foregroundColor(Color(UIColor.secondaryLabel))

                                    Spacer()

                                    Text(hit!.part)
                                        .font(.footnote)
                                        .foregroundColor(Color.accentColor)
                                        .padding(5)
                                        .background(
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(Color(UIColor.secondarySystemBackground))
                                        )
                                }
                            }

                            Spacer()
                        }
                        .padding(5)
                        .onTapGesture {
                            self.selectedExercise = hit!
                        }
                    }

                }//:HITSLIST
            }
            .disabled(isPresentSheet || isPresentRecord)
            .padding(.horizontal)
            
            
            //2. 필터 뷰
            if isPresentSheet{
                facets()
                    .transition(.scale)
            }
            
        }//:ZSTACK
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedExercise,onDismiss: {
            self.selectedExercise = nil
        }) { exercise in
            if ["Aerobic","Compound"].contains(exercise.part){
                userExerciseAerobicView(data: exercise)
                    .environmentObject(self.viewModel)
            }else{
                userExerciseRecordAnAerobic(namespace: namespace, data: exercise)
                    .environmentObject(self.viewModel)
            }
        }
        
    }
    
    
    
    @ViewBuilder
    func facets() -> some View{
        VStack{
            HStack(spacing:0){
                Text("필터 지정")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.vertical,5)
            
            FacetList(facetListController) { facet, isSelected in
                let realFacet = Facet(value: exercisePart(rawValue: facet.value)!.description, count: facet.count)
                FacetRow(facet: realFacet, isSelected: isSelected)
                    .padding(.vertical,10)
            } noResults: {
                Text("No facet found")
            }
            
            Button {
                isPresentSheet.toggle()
                
            } label: {
                Text("저장")
                    .foregroundColor(.white)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth:UIScreen.main.bounds.width)
                    .padding(10)
                    .background(Color.accentColor)
                    .cornerRadius(20)
            }
            .buttonStyle(.plain)
            
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(20)
        .padding()
    }
    
    @ViewBuilder
    func userRecordExerciseView(selectedExercise:exerciseResult) -> some View{
        VStack {
            Spacer()
            Text(selectedExercise.exerciseName)
            Spacer()
        }
        .background(.gray)
    }
}

struct userExerciseRecordAnAerobic:View{
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel:userExerciseSearchViewModel
    let namespace:Namespace.ID
    let data:exerciseResult
    @State private var showText:Bool = false
    @State var weightInput:String = ""
    @State var numberInput:String = ""
    @State var setInput:String = ""
    
    private func calTime()->Int{
        guard let userSet = Double(setInput),
              let userNumber = Double(numberInput) else{return 0}
        let minute = (userSet * userNumber * 5)/60
        
        if Int(minute) < 2{
            return 1
        }else{
            return Int(minute)
        }
    }
    
    var body: some View{
        NavigationView {
            VStack(alignment:.leading){
                KFImage(URL(string: data.url))
                    .onFailureImage(KFCrossPlatformImage(named: "defaultImage"))
                    .resizable()
                    .scaledToFill()
                    .frame(width:UIScreen.main.bounds.width,height: 300)
                    .clipped()
                
                ScrollView{
                    Group{
                        TextField("0", text: $weightInput)
                            .textFieldStyle(userExerciseInputTextFieldStyle(titleText: "무게", unitText: "kg"))
                        TextField("0", text: $numberInput)
                            .textFieldStyle(userExerciseInputTextFieldStyle(titleText: "횟수", unitText: "회"))
                        TextField("0", text: $setInput)
                            .textFieldStyle(userExerciseInputTextFieldStyle(titleText: "세트수", unitText: "세트"))
                    }
                    .padding()
                }
            }
            .navigationTitle(data.exerciseName)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(UIColor.systemBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        let values:[String:Any] = [
                            "engName":data.engName,
                            "exerciseName":data.exerciseName,
                            "expectKcal":viewModel.calUserData(data.parameter, settingTime: calTime()),
                            "hydro":data.hydro,
                            "minute":calTime(),
                            "parameter":data.parameter,
                            "part":data.part,
                            "set":setInput,
                            "time":numberInput,
                            "url":data.url,
                            "weight":weightInput
                        ]
                        viewModel.updateDataBase(values) {
                            dismiss.callAsFunction()
                        }
                    } label: {
                        Text("저장하기")
                    }
                    
                }
            }
        }
        
        
    }
}

struct userExerciseAerobicView:View{
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel:userExerciseSearchViewModel
    let data:exerciseResult
    @State var timeInput:String = ""
    var body: some View{
        NavigationView{
            VStack(alignment:.leading){
                KFImage(URL(string: data.url))
                    .onFailureImage(KFCrossPlatformImage(named: "defaultImage"))
                    .resizable()
                    .scaledToFill()
                    .frame(width:UIScreen.main.bounds.width,height: 300)
                    .clipped()
                
                ScrollView{
                    TextField("0", text: $timeInput)
                        .textFieldStyle(userExerciseInputTextFieldStyle(titleText: "운동 시간", unitText: "분"))
                }
                .padding()
            }
            .navigationTitle(data.exerciseName)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(UIColor.systemBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        let values:[String:Any] = [
                            "engName":data.engName,
                            "exerciseName":data.exerciseName,
                            "expectKcal":viewModel.calUserData(data.parameter, settingTime: Int(timeInput) ?? 1),
                            "hydro":data.hydro,
                            "minute":Int(timeInput) ?? 1,
                            "parameter":data.parameter,
                            "part":data.part,
                            "url":data.url
                        ]
                        viewModel.updateDataBase(values) {
                            dismiss.callAsFunction()
                        }
                    } label: {
                        Text("저장하기")
                    }

                }
            }
        }
    }
}

struct userExerciseInputTextFieldStyle:TextFieldStyle{
    let titleText:String
    let unitText:String
    func _body(configuration:TextField<Self._Label>)-> some View{
        HStack(alignment:.center){
            Text(titleText)
            Spacer()
            HStack(alignment:.center){
                configuration
                    .frame(width:50)
                Text(unitText)
                    .frame(width:50)
            }
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal,20)
        .padding(.vertical,10)
        .background(backgroundColor)
        .cornerRadius(10)
        
    }
}

struct userExerciseSearchView_preview:PreviewProvider{
    @Namespace static var namespace
    static let controller = ExerciseSearchController()
    static var previews: some View{
        
        Group{
            userExerciseSearchView(hitsController: controller.hitsController,
                                   queryController: controller.searchBoxController,
                                   facetListController: controller.facetListController)
            
            //            NavigationView{
            //                userExerciseRecordAnAerobic(namespace: namespace, data: exerciseResult(exerciseName: "푸시업", part: "등", hydro: "AnAerobic", engName: "asdnjkansd", parameter: 2.0, url: ""), show: .constant(true))
            //            }
            
            //            TextField("0", text: .constant(""))
            //                .textFieldStyle(userExerciseInputTextFieldStyle(titleText: "무게", unitText: "kg"))
            //                .previewLayout(.sizeThatFits)
            //                .padding()
        }
        
        
        
    }
}
