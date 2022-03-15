//
//  AllStretchingView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/16.
//

import SwiftUI

struct AllStretchingView: View {
    let stretchings:[Stretching] = Bundle.main.decode("Stretching.json")
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(stretchings.indices,id:\.self) { index in
                NavigationLink {
                    YouTubeView(index: index,
                                videoTitle: stretchings[index].title,
                                videoExplain: stretchings[index].explain,
                                videoId: stretchings[index].videoID,
                                isDone: false,
                                type: .all,
                                selectedDate: .constant(Date()))
                } label: {
                    StretchingCellView(stretching: stretchings[index])
                }
                .buttonStyle(.plain)
            }
        }
        
    }
}

struct StretchingCellView:View{
    let stretching:Stretching
    var body: some View{
        HStack{
            AsyncImage(url: URL(string: "https://img.youtube.com/vi/\(stretching.videoID)/maxresdefault.jpg")) { phase in
                
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
                Text(stretching.title)
                    .font(.title2)
                    .fontWeight(.heavy)
                
                Text(stretching.explain)
                    .font(.system(size: 13))
                    .fontWeight(.regular)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}


struct AllStretchingView_Previews: PreviewProvider {
    static let stretchings:[Stretching] = Bundle.main.decode("Stretching.json")
    static var previews: some View {
        AllStretchingView()
    }
}
