//
//  ExerciseStorageView.swift
//  Salud0.2
//
//  Created by 이관형 on 2022/01/06.
//

import SwiftUI
import FirebaseAuth

struct ExerciseStorageView: View {
    @State var selection = 0
    @State var searchedText: String = ""
    @State var isPresentAlertView: Bool = false
    @State var selectedExerciseName: String? = nil
    @State var searching:Bool = false
    @ObservedObject var viewModel = ExerciseStorageViewModel()
    @State var searchedPart: String?
    var uid: String = Auth.auth().currentUser?.uid ?? "default"
    var part = ["Aerobic", "Back", "Chest", "Leg", "Arm", "Abs", "Shoulder"]
    
    //MARK: - FUCTIONS
    private func changeDescription(_ rowString:String) -> String{
        var description:String = ""
        
        if rowString == "Aerobic"{
            description = "유산소"
        }else if rowString == "Back"{
            description = "등"
        }else if rowString == "Chest"{
            description = "가슴"
        }else if rowString == "Abs"{
            description = "복근"
        }else if rowString == "Arm"{
            description = "팔"
        }else if rowString == "Leg"{
            description = "하체"
        }else if rowString == "Shoulder"{
            description = "어깨"
        }else if rowString == "Fitness"{
            description = "센터 운동"
        }
        
        return description
    }
    
    var body: some View {
        VStack{
            HStack{
                Picker("", selection: $selection) {
                    ForEach(part.indices,id:\.self){ index in
                        Text(changeDescription(part[index]))
                    }
                }
                .onChange(of: selection) { newValue in
                    viewModel.StorageList.removeAll(keepingCapacity: true)
                    searchedText = ""
                }
                .padding(.leading,10)
                
                Divider()
                
                TextField("", text: $searchedText)
                
                Button {
                    if searchedText.count > 1{
                        self.searching = true
                        if selection == 0{
                            viewModel.getAerobicExercise(searchedText) {
                                self.searching = false
                            }
                        }else{
                            viewModel.getAnaerobicExercise(part[selection], searchedText) {
                                self.searching = false
                            }
                        }
                    }else{
                        isPresentAlertView = true
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 25))
                        .foregroundColor(.gray.opacity(0.2))
                }
                .padding(.trailing,10)
            }
            .background(.white)
            .cornerRadius(3)
            .padding(.horizontal)
            .padding(.top)
            .alert(isPresented: $isPresentAlertView){
                Alert(title: Text(""), message: Text("운동 명칭을 한자 이상 입력해주세요."),
                      dismissButton: .default(Text("확인")))
            }
            .frame(height: 60, alignment: .center)
            
            
            if self.viewModel.StorageList.count > 0{
                ScrollView(.vertical, showsIndicators: false){
                    ForEach(viewModel.StorageList.indices, id: \.self){ index in
                        
                        SelectionCell(item: viewModel.StorageList[index],
                                      alreadyItem: viewModel.alreadyList,
                                      searchpart: part[selection],
                                      selectedExerciseName: self.$selectedExerciseName,
                                      index:index
                        )
                        .environmentObject(self.viewModel)
                    }
                }
                .background(.white)
                .padding()
                .cornerRadius(3)
            }else if searching{
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
                Spacer()
            }else{
                Spacer()
                Text("검색된 운동이 없습니다.")
                Spacer()
            }
        }
        .background(backgroundColor.edgesIgnoringSafeArea(.all))
        .onTapGesture(count: 1) {
            UIApplication.shared.endEditing()
        }
    }
    
}

struct ExerciseStorageView_Previews:PreviewProvider{
    static var previews: some View{
        Group{
            ExerciseStorageView()
        }
        
    }
}


struct SelectionCell: View{
    let item: StorageExerciseModel
    let alreadyItem: [String]
    let searchpart:String
    @Binding var selectedExerciseName: String?
    @State var storeExerciseCheck: Bool = false
    @EnvironmentObject var viewModel:ExerciseStorageViewModel
    let index:Int
    let uid: String = Auth.auth().currentUser?.uid ?? "default"
    var body: some View{
        HStack{
            URLImageView(urlString: item.exerciseURL, imageSize: 50, youtube: false)
            
            VStack(alignment:.leading,spacing: 5){
                Text(String(item.exerciseName))
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.5)
                
                Text(String(item.exerciseEngName))
                    .font(.body)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button {
                if item.iscontains{
                    viewModel.deleteExistingExercise(searchpart, item.exerciseName) {
                        viewModel.StorageList[index].iscontains = false
                    }
                }else{
                    viewModel.setExerciseStorage(part: searchpart, item: item) {
                        viewModel.StorageList[index].iscontains = true
                    }
                }
            } label: {
                Image(systemName: item.iscontains ? "checkmark.circle":"circle")
                    .foregroundColor(item.iscontains ? .gray:.accentColor)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
        .padding(.vertical,5)
    }
}
@ViewBuilder
func placeholderImage() -> some View {
    Image(systemName: "photo")
        .renderingMode(.template)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 100, height: 100)
        .foregroundColor(.gray)
}


extension Image{
    func data(url: URL) -> Self{
        if let data = try? Data(contentsOf: url){
            return Image(uiImage: UIImage(data: data)!)
                .resizable()
        }
        return self
            .resizable()
    }
}
