//
//  ChattingImageView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/10.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseStorageUI
import SDWebImage
import Firebase

struct ChattingImageView: View {
    let currentUser:Bool
    let userImage:String?
    let urlPath:String
    let trainerId:String
    let userId:String
    let fitnessCode:String
    
    var body: some View {
        
        if currentUser{
            HStack{
                
                ImageElementView(urlPath: urlPath, fitnessCode: fitnessCode, trainerId: trainerId, userId: userId, isCurrentUser: currentUser)
                
                Spacer()
            }
            
            
        }else{
            
            HStack(alignment:.bottom){
                Spacer()
                ImageElementView(urlPath: urlPath, fitnessCode: fitnessCode, trainerId: trainerId, userId: userId, isCurrentUser: currentUser)
                URLImageView(urlString: userImage, imageSize: 30, youtube: false)
                    .rotationEffect(Angle(degrees: -180))
            }
            .onAppear {
                print("is current User \(currentUser)")
            }
        }
        
    }
}


struct ImageElementView:View{
    let urlPath:String
    let fitnessCode:String
    let trainerId:String
    let userId:String
    let isCurrentUser:Bool
    @State var isOpen:Bool = false
    @State var image:UIImage = UIImage()
    @State var isHidden:Bool = false
    
    @State var progressHeight:CGFloat = 400
    @State var progrssWidth:CGFloat = 300
    
    private func ImageUrl()->URL?{
        guard let compareId = Firebase.Auth.auth().currentUser?.uid else{return URL(string: "")}
        
        var sub = ""
        if compareId == trainerId{
            if isCurrentUser{
                sub = "ChatsImage%2F\(fitnessCode)%2F\(trainerId)%2F\(userId)%2F"
            }else{
                sub = "ChatsImage%2F\(fitnessCode)%2F\(userId)%2F\(trainerId)%2F"
            }
        }else {
            if isCurrentUser{
                sub = "ChatsImage%2F\(fitnessCode)%2F\(userId)%2F\(trainerId)%2F"
            }else{
                sub = "ChatsImage%2F\(fitnessCode)%2F\(trainerId)%2F\(userId)%2F"
            }
        }
        let baseUrl = "https://firebasestorage.googleapis.com/v0/b/pton-1ffc0.appspot.com/o/"
        let query = "?alt=media"
        let path = urlPath.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let url = URL(string: baseUrl + sub + path + query)
        
        return url
    }
    var body: some View{
        ZStack{
            
            WebImage(url: ImageUrl())
                .resizable()
                .indicator(.progress(style: .default))
                .scaledToFit()
                .frame(maxHeight:400)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.white)
                )
            
        }
        .cornerRadius(8)
        .onTapGesture {
            isOpen = true
        }
        .fullScreenCover(isPresented: $isOpen) {
            ZoomImageView(image: image, isOpen: $isOpen)
        }
        .rotationEffect(.degrees(-180))
    }
}


struct ZoomImageView:View{
    let image:UIImage
    @Binding var isOpen:Bool
    @State var imageScale:CGFloat = 1
    @State var imageOffset:CGSize = .zero
    @State var isShowBar:Bool = false
    
    func resetImageState() {
        return withAnimation(.spring()) {
            imageScale = 1
            imageOffset = .zero
        }
    }
    
    var body: some View{
        VStack{
            
            HStack{
                if isShowBar{
                    Button {
                        isOpen = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 25))
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .background(.clear)
            
            Spacer()
            
            
            Image(uiImage: image)
                .resizable()
                .scaleEffect(imageScale)
                .aspectRatio(contentMode: .fit)
                .offset(x: imageOffset.width, y: imageOffset.height)
            //MARK: - 2. TWO TAP GESTURE
                .onTapGesture(count: 2, perform: {
                    if imageScale == 1 {
                        withAnimation(.spring()) {
                            imageScale = 5
                        }
                    } else {
                        resetImageState()
                    }
                })
            //MARK: - 2. ONE TAP GESTURE
                .onTapGesture(count: 1, perform: {
                    withAnimation {
                        isShowBar.toggle()
                    }
                    
                })
            // MARK: - 3. DRAG GESTURE
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            withAnimation(.linear(duration: 1)){
                                if imageScale == 1{
                                    imageOffset.height = value.translation.height
                                }else{
                                    imageOffset = value.translation
                                }
                            }
                        }
                        .onEnded { value in
                            if (value.startLocation.y - value.predictedEndLocation.y) < 100 && imageScale == 1{
                                withAnimation(.spring()){
                                    isOpen = false
                                }
                            }else{
                                resetImageState()
                            }
                        }
                )
            // MARK: - 4. MAGNIFICATION
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            withAnimation(.linear(duration: 1)) {
                                if imageScale >= 1 && imageScale <= 5 {
                                    imageScale = value
                                } else if imageScale > 5 {
                                    imageScale = 5
                                } else {
                                    resetImageState()
                                }
                            }
                        }
                        .onEnded { _ in
                            if imageScale > 5 {
                                imageScale = 5
                            } else if imageScale <= 1 {
                                resetImageState()
                            }
                        }
                )
            
            Spacer()
        }
        .background(.black)
    }
}

//struct ChattingImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChattingImageView(viewmodel: ChattingImageViewModel("ChatsImage_kakao:1967260938_03-11_14:44.jpg"), currentUser: false, userImage: "")
//            .previewLayout(.sizeThatFits)
//            .rotationEffect(.degrees(-180))
//    }
//}
