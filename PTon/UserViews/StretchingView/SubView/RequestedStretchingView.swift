//
//  RequestedStretchingView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/16.
//

import SwiftUI

struct RequestedStretchingView: View {
    @StateObject var viewmodel:RequestStretchingViewModel
    var body: some View {
        VStack{
            
            weekDatePickerView(currentDate: $viewmodel.currentDate)
                .padding(.horizontal)
                .padding(.bottom,10)
                .onChange(of: viewmodel.currentDate) { newValue in
                    viewmodel.reloadData()
                }
            
            
            if viewmodel.memberStretchings.isEmpty{
                VStack(spacing:0){
                    VStack{
                        Spacer()
                        
                        HStack(spacing:0){
                            Spacer()
                            
                            Text("지정된 날짜에 요청된 스트레칭이 없습니다.")
                                .foregroundColor(.gray.opacity(0.8))
                                .font(.system(size: 15))
                                .multilineTextAlignment(.center)
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    .background(.white)
                    .cornerRadius(3)
                    .padding(.horizontal,18)
                    .padding(.vertical,25)
                    .shadow(color: .gray.opacity(0.2), radius: 5)
                }
                .background(backgroundColor)
                
            }else{
                VStack{
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(viewmodel.memberStretchings,id:\.self) { item in
                            
                            NavigationLink {
                                YouTubeView(index: item.index,
                                            videoTitle: item.video.title,
                                            videoExplain: item.video.explain,
                                            videoId: item.video.videoID,
                                            isDone: item.isDone,
                                            type: .request,
                                            selectedDate: $viewmodel.currentDate)
                                .environmentObject(self.viewmodel)
                            } label: {
                                RequestStretchingCellView(stretching: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .background(.white)
                    .cornerRadius(3)
                    .padding(.horizontal,15)
                    .padding(.vertical,25)
                    .shadow(color: .gray.opacity(0.2), radius: 5)
                    
                }
                .background(backgroundColor)
            }
                
        }
        
    }
}

struct RequestStretchingCellView:View{
    let stretching:memberStretching
    var body: some View{
        HStack{
            URLImageView(urlString: "https://img.youtube.com/vi/\(stretching.video.videoID)/maxresdefault.jpg", imageSize: 50, youtube: true)
            
            Divider()
            
            VStack(alignment:.leading){
                Text(stretching.video.title)
                    .font(.title2)
                    .fontWeight(.heavy)
                
                Text(stretching.video.explain)
                    .font(.system(size: 13))
                    .fontWeight(.regular)
                    .lineLimit(2)
            }
        }
        .padding(.horizontal,20)
        .padding(.vertical,10)
    }
}

struct RequestedStretchingView_Previews: PreviewProvider {
    static var previews: some View {
        RequestedStretchingView(viewmodel: RequestStretchingViewModel(trainerid: "3yvE0bnUEHbvDKasU1Orf7DhvjX2", userid: "kakao:1967260938"))
    }
}
