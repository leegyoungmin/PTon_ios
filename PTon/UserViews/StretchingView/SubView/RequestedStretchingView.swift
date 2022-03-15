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
            DatePicker(selection: $viewmodel.currentDate, displayedComponents: .date) {
                Text("요청된 날짜")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .datePickerStyle(.compact)
            .environment(\.locale, Locale(identifier: "ko_KR"))
            .padding(.horizontal)
            .onChange(of: viewmodel.currentDate) { newValue in
                print("new date Value in DatePicker \(newValue)")
                viewmodel.reloadData()
                
                print("viewmodel member Stretchings \(viewmodel.memberStretchings)")
            }
            if viewmodel.memberStretchings.isEmpty{
                Spacer()
                Text("요청된 스트레칭이 없습니다.\n채팅을 통해서 요청해보세요.\n😂😂😂😂")
                    .multilineTextAlignment(.center)
                Spacer()
            }else{
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
            }
        }
        
    }
}

struct RequestStretchingCellView:View{
    let stretching:memberStretching
    var body: some View{
        HStack{
            AsyncImage(url: URL(string: "https://img.youtube.com/vi/\(stretching.video.videoID)/maxresdefault.jpg")) { phase in
                
                switch phase{
                case .empty:
                    VStack{
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                    .frame(width: 100, height: 60, alignment: .center)
                case .success(let image):
                    image.resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 60, alignment: .leading)
                case .failure(_):
                    Image(systemName: "xmark")
                        .scaledToFit()
                        .frame(width: 100, height: 60, alignment: .center)
                @unknown default:
                    VStack{
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                    .frame(width: 100, height: 60, alignment: .center)
                }
            }
            
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
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct RequestedStretchingView_Previews: PreviewProvider {
    static var previews: some View {
        RequestedStretchingView(viewmodel: RequestStretchingViewModel(trainerid: "asndj", userid: "asndk"))
    }
}
