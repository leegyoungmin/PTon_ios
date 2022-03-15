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
    
    
    var body: some View {
        VStack{
            HStack{
                Picker("", selection: $selection) {
                    ForEach(0..<part.count){
                        Text(part[$0])
                    }
                }
                .onChange(of: selection) { newValue in
                    viewModel.StorageList.removeAll(keepingCapacity: true)
                    searchedText = ""
                }
                
                TextField("", text: $searchedText)
                    .textFieldStyle(.roundedBorder)
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
                        .foregroundColor(.black)
                        .font(.system(size: 30))
                        .frame(width: 50, height: 50, alignment: .trailing)
                }
            }
            .padding(.horizontal)
            .alert(isPresented: $isPresentAlertView){
                Alert(title: Text(""), message: Text("운동 명칭을 한자 이상 입력해주세요."),
                      dismissButton: .default(Text("확인")))
            }
            
            if self.viewModel.StorageList.count > 0{
                List{
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
                .listStyle(.plain)
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
        
        VStack {
            Divider()
            HStack{
                HStack{
                    AsyncImage(
                        url: URL(string: item.exerciseURL),
                        content: { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 50, maxHeight: 50)
                        }, placeholder: {
                            ProgressView()
                                .frame(width: 50, height: 50, alignment: .center)
                        })
                    VStack(alignment:.leading){
                        Text(String(item.exerciseName))
                            .font(.title3)
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
                    Text(item.iscontains ? "담음":"담기")
                        .padding(.horizontal)
                        .padding(.vertical,5)
                        .foregroundColor(item.iscontains ? .white:.black)
                }
                .disabled(storeExerciseCheck)
                .buttonStyle(PlainButtonStyle())
                .background(item.iscontains ? .gray:.purple)
                .cornerRadius(25)
            }
        }
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
