//
//  VideoPlayer.swift
//  PTon
//
//  Created by 이경민 on 2022/02/18.
//

import Foundation
import WebKit
import SwiftUI

struct VideoView:UIViewRepresentable{
    let videoId:String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let youtubeURL = URL(string: "https://www.youtube.com/embed/\(videoId)") else{return}
        uiView.scrollView.isScrollEnabled = false
        uiView.load(URLRequest(url: youtubeURL))
    }
}
