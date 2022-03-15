//
//  YouTubeView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/18.
//

import SwiftUI
import AVKit

struct YouTubeView: View {
    let index:Int
    let videoTitle:String
    let videoExplain:String
    let videoId:String
    let isDone:Bool
    let type:StretchingType
    @Binding var selectedDate:Date
    @State var errorAlert:Bool = false
    
    @EnvironmentObject var requestedViewModel:RequestStretchingViewModel
    
    var body: some View {
        VStack{
            VideoView(videoId: videoId)
                .frame(minHeight:0,maxHeight: UIScreen.main.bounds.height*0.3)
                .cornerRadius(12)
            
            VStack(alignment:.leading){
                Text(videoTitle)
                    .font(.title)
                    .fontWeight(.heavy)
                    .padding(.vertical,10)
                
                Text(videoExplain)
                    .font(.body)
                    .fontWeight(.semibold)
            }

            if type == .request{
                VStack {
                    Button {
                        self.requestedViewModel.uploadData(selectedDate, self.index) {
                            self.errorAlert = true
                        }
                    } label: {
                        Text("시청 완료")
                            .font(.body)
                            .fontWeight(.semibold)
                            .frame(width: UIScreen.main.bounds.width*0.9)
                            .padding(.vertical,10)
                            .background(.purple)
                            .cornerRadius(20)
                            .foregroundColor(.white)
                            
                    }
                    .buttonStyle(.plain)
                    .disabled(isDone ? true:false)
                    .tint(isDone ? .gray.opacity(0.5):.purple)
                    
                    Spacer()
                }
                .padding(.vertical,5)
            }else{
                Spacer()
            }

        }
        .padding()
        .alert("당일 일정만 완료가 가능합니다.", isPresented: $errorAlert) {
            Button("확인") {
                self.errorAlert = false
            }
            .tint(.purple)
        }
    }
}

struct YouTubeView_Previews: PreviewProvider {
    static var previews: some View {
        YouTubeView(index: 1, videoTitle: "asndjk", videoExplain: "asndkasdasndkasdasndkasdasndkasdasndkasdasndkasdasndkasdasndkasdasndkasdasndkasdasndkasdasndkasdasndkasdasndkasd", videoId: "asndjk", isDone: false, type: .request, selectedDate: .constant(Date()))
    }
}

extension RequestStretchingViewModel{
    func uploadData(_ selectedDate:Date,_ index:Int,completion:@escaping()->Void){
        if convertDateToString(date: self.currentDate) == convertDateToString(date: Date()){
            reference
                .child("MemberStretch")
                .child(self.userid)
                .child(convertDateToString(date: selectedDate))
                .child(String(index))
                .setValue(true)
        }else{
            completion()
        }
    }
}
