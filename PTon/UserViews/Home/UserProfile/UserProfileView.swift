//
//  UserProfileView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/15.
//

import SwiftUI
import ToastUI
import Firebase
import AlertToast
import SDWebImageSwiftUI

struct UserProfileView: View {
    @EnvironmentObject var viewmodel:UserBaseViewModel
    @Environment(\.dismiss) var dismiss
    @State var isChanged = false
    @State private var showSheet = false
    @State private var showToast = false
    @State private var saveDataProcess = false
    
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Image(systemName: "xmark")
                        .font(.system(size: 25))
                    Spacer()
                }
                Spacer()
            }
            .padding()
            .onTapGesture {
                viewDismiss()
            }
            .blur(radius: isChanged ? 2:0)
            .disabled(isChanged)
            
            VStack(spacing:50){
                WebImage(url: URL(string: viewmodel.imageUrl))
                    .placeholder(
                        Image("defaultImage")
                    )
                    .resizable()
                    .frame(width: 300, height: 300, alignment: .center)
                    .clipShape(Circle())
                
                

                
                HStack(spacing:100){
                    Button {
                        self.showSheet = true
                    } label: {
                        VStack(spacing:5){
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 30))
                            
                            Text("사진 변경")
                                .font(.headline)
                                .foregroundColor(.purple)
                        }
                    }

                    
                    Button {
                        print("Tapped Kcal Setting Button")
                        self.showToast = true
                    } label: {
                        VStack(spacing:5){
                            Image(systemName: "rosette")
                                .font(.system(size: 30))
                            
                            Text("목표 변경")
                                .font(.headline)
                                .foregroundColor(.purple)
                        }
                    }
                }
                
            }
            .blur(radius: isChanged ? 2:0)
            .disabled(isChanged)
            
            if isChanged{
                ProgressView()
                    .progressViewStyle(.circular)

            }
        }
        .sheet(isPresented: $showSheet) {
            ImagePickerView(isChanged: $isChanged)
                .environmentObject(self.viewmodel)
        }
        .toast(isPresenting: $saveDataProcess, alert: {
            AlertToast(displayMode: .alert, type: .loading,title: nil)
        })
        .toast(isPresented: $showToast) {
            ToastView{
                KcalSettingView(showToast: $showToast)
            }
            .padding()
        }
        
    }
    
    func viewDismiss(){
        self.saveDataProcess = false
        dismiss.callAsFunction()
    }
}

struct KcalSettingView:View{
    @StateObject var viewmodel = KcalSettingViewModel()
    @Binding var showToast:Bool
    var body: some View{
        VStack(alignment:.center,spacing:10){
            HStack{
                Spacer()
                Image(systemName: "rosette")
                    .font(.system(size: 50))
                Spacer()
            }
            TextField("목표 칼로리를 작성해주세요.", text: $viewmodel.settingText)
                .textFieldStyle(.roundedBorder)
            
            Button {
                self.viewmodel.uploadData()
                self.showToast = false
            } label: {
                HStack{
                    Image(systemName: "arrow.up.to.line.circle.fill")
                        .font(.system(size: 20))

                    Text("저장하기")
                        .font(.system(size: 15))
                }
                .padding(.vertical,5)
                .padding(.horizontal,30)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.purple,lineWidth: 2)
                )
            }
            .buttonStyle(.plain)

        }
        .padding()
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(isChanged:false)
            .environmentObject(UserBaseViewModel())
//        KcalSettingView(showToast: .constant(true))
//            .previewLayout(.sizeThatFits )
    }
}

extension UserBaseViewModel{
    func uploadData(_ image:UIImage,completion:@escaping()->Void){
        let storageRef = Storage.storage().reference().child("Profile")
            .child("Profile"+getCurrentDate())
        
        var data = Data()
        data = image.jpegData(compressionQuality: 0.8)!
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        
        storageRef.putData(data, metadata: metaData) { meta, error in
            if let error = error{
                print(error.localizedDescription)
            }else{
                storageRef.downloadURL { url, error in
                    if error == nil{
                        guard let path = url?.absoluteString,
                              let userid = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
                        self.userBaseModel.imageUrl = path
                        
                        completion()
                        
                        Database.database().reference()
                            .child("User")
                            .child(userid)
                            .child("photoUri")
                            .setValue(path)
                    }
                }
            }
        }
    }
    
    func getCurrentDate()->String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMdd_HHmmss"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}
