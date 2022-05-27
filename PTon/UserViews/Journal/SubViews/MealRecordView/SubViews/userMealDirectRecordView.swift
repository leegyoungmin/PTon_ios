//
//  userMealDirectRecordView.swift
//  PTon
//
//  Created by 이경민 on 2022/05/25.
//

import SwiftUI
import AlertToast

enum photoType:Int,Identifiable{
    var id:RawValue{rawValue}
    case camera
    case library
}

struct userMealDirectRecordView: View {
    //MARK: - PROPERTIES
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel:UserMealViewModel
    let index:Int
    @State var foodName:String = ""
    @State var foodKcal:String = ""
    @State var foodGram:String = ""
    @State var foodCarbs:String = ""
    @State var foodProtein:String = ""
    @State var foodFat:String = ""
    @State var foodSodium:String = ""
    
    //MARK: - VIEW PROPERTIES
    @State var isPresentPhotoView:Bool = false
    @State var userPhoto = UIImage()
    @State var photoPickerType:photoType?
    @State var isShowLoading:Bool = false
    @State var isShowError:Bool = false
    
    //MARK: - BODY
    var body: some View {
        NavigationView{
            ScrollView(.vertical, showsIndicators: false) {
                VStack{
                    DirectRecordTitleView(title: "사진")
                        .padding(.vertical,5)
                    //1. 사진 기록하기
                    
                    if userPhoto.size == .zero{
                        RoundedRectangle(cornerRadius: 15)
                            .frame(height:UIScreen.main.bounds.width/2)
                            .foregroundColor(backgroundColor)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 50))
                                    .foregroundColor(.accentColor)
                            )
                            .onTapGesture {
                                withAnimation {
                                    isPresentPhotoView = true
                                }
                            }
                    }else{
                        Image(uiImage: userPhoto)
                            .resizable()
                            .frame(minHeight:UIScreen.main.bounds.width/2)
                            .scaledToFit()
                            .cornerRadius(15)
                            .onTapGesture {
                                withAnimation {
                                    isPresentPhotoView = true
                                }
                            }
                    }
                    

                    
                    DirectRecordTitleView(title: "영양정보")
                        .padding(.vertical)
                    
                    //2. 메뉴명
                    TextField("", text: $foodName)
                        .textFieldStyle(DirectMealTextFieldStyle(title: "메뉴명",unit: nil))
                    //3. 칼로리
                    TextField("", text: $foodKcal)
                        .textFieldStyle(DirectMealTextFieldStyle(title: "칼로리정보",unit: "kcal"))
                    
                    //4. 1인분
                    TextField("", text: $foodGram)
                        .textFieldStyle(DirectMealTextFieldStyle(title: "1인분", unit: "g"))
                    
                    //5. 탄수화물,단백질,지방 기록
                    VStack{
                        HStack(alignment:.center){
                            Text("탄수화물")
                                .fontWeight(.semibold)
                            Spacer()
                            
                            TextField("", text: $foodCarbs)
                                .padding(.vertical,3)
                                .frame(width:50)
                                .background(backgroundColor)
                                .cornerRadius(5)
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                            Text("g")
                                .frame(width:50)
                        }
                        
                        HStack(alignment:.center){
                            Text("단백질")
                                .fontWeight(.semibold)
                            Spacer()
                            
                            TextField("", text: $foodProtein)
                                .padding(.vertical,3)
                                .frame(width:50)
                                .background(backgroundColor)
                                .cornerRadius(5)
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                            Text("g")
                                .frame(width:50)
                        }
                        
                        HStack(alignment:.center){
                            Text("지방")
                                .fontWeight(.semibold)
                            Spacer()
                            
                            TextField("", text: $foodFat)
                                .padding(.vertical,3)
                                .frame(width:50)
                                .background(backgroundColor)
                                .cornerRadius(5)
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                            Text("g")
                                .frame(width:50)
                        }
                        
                        HStack(alignment:.center){
                            Text("나트륨")
                                .fontWeight(.semibold)
                            Spacer()
                            
                            TextField("", text: $foodSodium)
                                .padding(.vertical,3)
                                .frame(width:50)
                                .background(backgroundColor)
                                .cornerRadius(5)
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                            Text("mg")
                                .frame(width:50)
                        }
                    }//:VSTACK
                    .padding(.vertical)
                }//:VSTACK
                .padding(.horizontal)
                .navigationTitle("식사 추가")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss.callAsFunction()
                        } label: {
                            Text("취소")
                        }
                        
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            if foodName.isEmpty{
                                isShowError = true
                            }else{
                                UIApplication.shared.endEditing()
                                isShowLoading = true
                                var data:[String:Any] = ["carbs":Int(foodCarbs) ?? 0,"fat":Int(foodFat) ?? 0,"foodName":foodName,"kcal":Int(foodKcal) ?? 0,"protein":Int(foodProtein) ?? 0,"sodium":Int(foodSodium) ?? 0]
                                
                                
                                if userPhoto.size != .zero{
                                    viewModel.uploadImage(image: userPhoto.jpegData(compressionQuality: 0.8)) { url in
                                        data["url"] = url
                                    }
                                }
                                
                                viewModel.updateDirect(index, data) {
                                    self.isShowLoading = false
                                    dismiss.callAsFunction()
                                }
                            }
                        } label: {
                            Text("음식 저장")
                        }
                        
                    }
                }//:TOOLBAR
            }//:SCROLLVIEW
            .fullScreenCover(item: $photoPickerType) { type in
                if type == .camera{
                    MealCameraView(image: $userPhoto, sourceType: .camera)
                }else{
                    MealImagePickerView(image: $userPhoto)
                }
            }//:FULLSCREENCOVER
            .confirmationDialog("사진 추가 방법", isPresented: $isPresentPhotoView) {
                Button {
                    self.photoPickerType = .camera
                } label: {
                    Text("사진 촬영")
                }
                
                Button {
                    self.photoPickerType = .library
                } label: {
                    Text("앨범 선택")
                }
            }//:CONFIRMDIALOG
            .toast(isPresenting: $isShowLoading, tapToDismiss: false) {
                AlertToast(displayMode: .alert, type: .loading,title: "음식을 저장중입니다.")
            }
            .toast(isPresenting: $isShowError, duration: 2, tapToDismiss: true) {
                AlertToast(displayMode: .banner(.slide), type: .error(.red), title: "음식 이름을 작성해주세요.")
            }
        }//:NAVIGATIONVIEW
        
    }
}

//MARK: - SUBVIEWS
struct DirectRecordTitleView:View{
    let title:String
    var body: some View{
        HStack{
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
        }
        .padding(.vertical,5)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .frame(height:1)
            ,alignment: .bottom
        )
    }
}

struct DirectMealTextFieldStyle:TextFieldStyle{
    let title:String
    let unit:String?
    func _body(configuration:TextField<Self._Label>)-> some View{
        VStack(alignment:.leading,spacing:10){
            Text(title)
                .fontWeight(.semibold)
            HStack{
                configuration
                
                if unit != nil{
                    Text(unit!)
                        .multilineTextAlignment(.trailing)
                        .padding(.trailing,10)
                }
            }
            .padding(8)
            .background(backgroundColor)
            .cornerRadius(10)
            
        }
    }
}

//MARK: - PREVIEWS
struct userMealDirectRecordView_Previews: PreviewProvider {
    static var previews: some View {
        userMealDirectRecordView(index: 0)
    }
}
