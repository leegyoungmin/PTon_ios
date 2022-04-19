//
//  AllStretchingView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/16.
//

import SwiftUI
import Kingfisher

struct AllStretchingView: View {
    let stretchings:[Stretching] = Bundle.main.decode("Stretching.json")
    var body: some View {
        VStack{
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
            .background(.white)
            .cornerRadius(3)
            .padding(.horizontal,18)
            .padding(.vertical,25)
            .shadow(color: .gray.opacity(0.2), radius: 5)
        }
        .background(backgroundColor)

        
    }
}

struct StretchingCellView:View{
    let stretching:Stretching
    var body: some View{
        HStack{
            
            
            KFImage(URL(string: "https://img.youtube.com/vi/\(stretching.videoID)/maxresdefault.jpg"))
                .resizable()
                .placeholder({
                    logoImage
                })
                .frame(width: 100, height: 60, alignment: .center)
            
            
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
        .padding(.horizontal,20)
        .padding(.vertical,10)
    }
}


struct AllStretchingView_Previews: PreviewProvider {
    static let stretchings:[Stretching] = Bundle.main.decode("Stretching.json")
    static var previews: some View {
        AllStretchingView()
    }
}
