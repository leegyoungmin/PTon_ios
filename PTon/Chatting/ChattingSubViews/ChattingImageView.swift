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

struct ChattingImageView: View {
    @StateObject var viewmodel:ChattingImageViewModel
    let currentUser:Bool
    let userImage:String?
    
    var body: some View {
        
        if currentUser{
            HStack{
                ImageElementView(isCurrentUser:currentUser)
                    .environmentObject(self.viewmodel)
                    .onAppear {
                        print("is current User \(currentUser)")
                    }
                Spacer()
            }

            
        }else{
            
            HStack(alignment:.bottom){
                Spacer()
                ImageElementView(isCurrentUser:currentUser)
                    .environmentObject(self.viewmodel)
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
    @EnvironmentObject var viewmodel:ChattingImageViewModel
    let isCurrentUser:Bool
    @State var isOpen:Bool = false
    @State var image:UIImage = UIImage()
    @State var isHidden:Bool = false
    
    @State var progressHeight:CGFloat = 400
    @State var progrssWidth:CGFloat = 300
    
    var body: some View{
        ZStack{
            
            WebImage(url: viewmodel.imageURL)
                .resizable()
                .placeholder(content: {
                    if isCurrentUser == true{
                        HStack{
                            Spacer()
                            ProgressView()
                                .progressViewStyle(.circular)
                                .frame(maxWidth:300,maxHeight:400)
                                .background(isHidden ? .clear:.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }else{
                        HStack{
                            
                            ProgressView()
                                .progressViewStyle(.circular)
                                .frame(maxWidth:300,maxHeight:400)
                                .background(isHidden ? .clear:.gray.opacity(0.2))
                                .cornerRadius(8)
                            Spacer()
                        }
                    }
                })
                .scaledToFit()
                .frame(maxHeight:400)
                .cornerRadius(8)
            
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
