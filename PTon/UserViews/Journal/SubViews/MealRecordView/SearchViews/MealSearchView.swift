//
//  MealSearchView.swift
//  PTon
//
//  Created by 이경민 on 2022/05/20.
//

import SwiftUI
import InstantSearchSwiftUI
import InstantSearchCore
import AlertToast

struct MealSearchView: View {
    @ObservedObject var queryInputController:QueryInputObservableController
    @ObservedObject var hitsController:HitsObservableController<foodResult>
    @Binding var isPresent:Bool
    @State private var isEditing = false
    let userId:String
    let trainerId:String
    let mealType:mealType
    
    var body: some View {
        NavigationView{
            HitsList(hitsController) { hit, _ in
                NavigationLink {
                    foodRecordView(isPresent: $isPresent, selectedFood: hit,viewModel: FoodRecordViewModel(userId: self.userId, trainerId: self.trainerId, mealtype: self.mealType))
                } label: {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack{
                            
                            VStack(alignment: .leading, spacing: 0){
                                Text(hit?.manufacture ?? "")
                                    .font(.callout)
                                
                                Text(hit?.foodName ?? "")
                                    .font(.body)
                                    .foregroundColor(.accentColor)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.callout)
                        }
                        
                        
                        Divider()
                    }
                    .padding(.horizontal,15)
                }
                .buttonStyle(.plain)
            } noResults: {
                if queryInputController.query.isEmpty{
                    Text("검색어를 입력해주세요.")
                }else{
                    Text("검색된 결과가 없습니다.")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $queryInputController.query, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isPresent = false
                    } label: {
                        Text("취소")
                    }

                }
            }
        }
        
    }
}

struct foodRecordView:View{
    @Binding var isPresent:Bool
    let selectedFood:foodResult?
    @State var inputValue:String = "1"
    @State var image = UIImage()
    @State var isPresentPicture:Bool = false
    @State var isPresentCamera:Bool = false
    @State var isPresentAlbum:Bool = false
    @State var isShowLoadingView:Bool = false
    @StateObject var viewModel:FoodRecordViewModel
    var body: some View{
        VStack(alignment:.leading){
            HStack{
                // 1. 사진 추가 버튼
                
                Button {
                    isPresentPicture = true
                } label: {
                    
                    if image.size == .zero{
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 150, height: 150, alignment: .center)
                            .foregroundColor(Color(UIColor.secondarySystemFill))
                            .overlay(
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.largeTitle)
                            )
                    }else{
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150, alignment: .center)
                            .cornerRadius(20)
                    }
                }
                .buttonStyle(.plain)
                
                // 2. 음식 이름 및 인분 데이터
                VStack(alignment:.leading,spacing: 5){
                    Text(selectedFood?.foodName ?? "")
                        .font(.title)
                        .fontWeight(.heavy)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text("1회 제공량 \(Int(selectedFood?.intake ?? 0))g")
                    
                    
                    HStack{
                        TextField("", text: $inputValue)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.center)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .keyboardType(.numberPad)
                        Text("인분")
                    }//:HSTACK
                }//:VSTACK
                
                Spacer()
            }//:HSTACK
            .padding(.horizontal)
            
            //영양정보 안내사항
            Text("칼로리 및 영양 정보는 식약처 정보에 따르며,그 양은 1회 제공량을 기준으로 합니다.")
                .font(.footnote)
                .foregroundColor(Color(UIColor.secondaryLabel))
                .padding(.horizontal)
            
            VStack(spacing:0){
                //3. 영양정보 타이틀
                HStack{
                    Text("영양정보")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                .padding(.top,10)
                
                //4. 영양 정보 카드 뷰
                nutrientCardView("전체 칼로리 정보", selectedFood?.kcal ?? 0, userKcal: viewModel.userAllKcal(), userCount: $inputValue)
                nutrientCardView("탄수화물", selectedFood?.carbsKcal ?? 0, userKcal: viewModel.userCarbo(), userCount: $inputValue)
                nutrientCardView("단백질", selectedFood?.proteinKcal ?? 0, userKcal: viewModel.userProtein(), userCount: $inputValue)
                nutrientCardView("지방", selectedFood?.fatKcal ?? 0, userKcal: viewModel.userProtein(), userCount: $inputValue)
                
            }
            .padding(.horizontal)
        }//:VSTACK
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isShowLoadingView = true
                    viewModel.uploadImage(imageData: image.jpegData(compressionQuality: 0.8)) { path in
                        if path != nil{
                            let data:[String:Any] = [
                                "foodName":selectedFood?.foodName ?? "",
                                "url":path!,
                                "intake":Int(selectedFood?.intake ?? 0) * Int(Double(inputValue) ?? 0),
                                "carbs":Int(selectedFood?.carbs ?? 0) * Int(Double(inputValue) ?? 0),
                                "protein":Int(selectedFood?.protein ?? 0)*Int(Double(inputValue) ?? 0),
                                "fat":Int(selectedFood?.fat ?? 0) * Int(Double(inputValue) ?? 0),
                                "kcal":Int(selectedFood?.kcal ?? 0) * Int(Double(inputValue) ?? 0),
                                "sodium":Int(selectedFood?.sodium ?? 0) * Int(Double(inputValue) ?? 0)
                            ]

                            viewModel.uploadUserRecord(userData: data)
                            self.isShowLoadingView = false
                            isPresent = false
                           
                        }
                    }
                    
                } label: {
                    Text("음식 추가")
                        .font(.system(size: 15))
                        .foregroundColor(.accentColor)
                }
                
            }
        }//:TOOLBAR
        .confirmationDialog("사진 선택 방법", isPresented: $isPresentPicture) {
            Button("카메라로 사진찍기", role: .none) {
                isPresentCamera = true
            }
            
            Button("엘범에서 선택하기", role: .none) {
                isPresentAlbum = true
            }
        }
        .fullScreenCover(isPresented: $isPresentCamera) {
            MealCameraView(image: $image, sourceType: .camera)
        }
        .fullScreenCover(isPresented: $isPresentAlbum) {
            MealImagePickerView(image: $image, isPresented: $isPresentAlbum)
        }
        .toast(isPresented: $isShowLoadingView) {
            AlertToast(displayMode: .alert, type: .loading)
        }
    }
}

struct nutrientCardView:View{
    let title:String
    let selectedFood:Double
    let userKcal:Int
    @Binding var userCount:String
    let ratio:CGFloat
    
    init(_ title:String,_ selectedFood:Double,userKcal:Int,userCount:Binding<String>){
        self.title = title
        self.selectedFood = selectedFood
        self.userKcal = userKcal
        _userCount = userCount
        
        self.ratio = CGFloat((selectedFood/Double(userKcal)))
    }
    
    var body: some View{
        
        VStack(alignment:.leading,spacing:0){
            HStack{
                Text(title)
                Spacer()
                Text("\(Int(selectedFood) * (Int(userCount) ?? 0))/\(userKcal) ")
                    .font(.title2)
                    .fontWeight(.bold)+Text("Kcal").foregroundColor(.secondary).font(.footnote)
            }
            
            GeometryReader { proxy in
                RoundedRectangle(cornerRadius: 10)
                    .frame(width:proxy.size.width,height:10)
                    .padding(.vertical)
                    .foregroundColor(Color(UIColor.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor((ratio * CGFloat(Double(userCount) ?? 1)) > 1 ? .red:.accentColor)
                            .frame(width:(ratio * CGFloat(Double(userCount) ?? 1)) > 1 ? proxy.size.width:(ratio * CGFloat(Double(userCount) ?? 1))*proxy.size.width,height:10)
                        ,alignment: .leading
                    )
                    .animation(.easeInOut, value: 3)
            }
            
        }
        .padding(.vertical)
    }
}

//struct MealSearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        MealSearchView()
//    }
//}
