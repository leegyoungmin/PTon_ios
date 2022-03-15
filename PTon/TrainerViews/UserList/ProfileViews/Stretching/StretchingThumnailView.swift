//
//  StretchingThumnailView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/13.
//

import SwiftUI
import WebKit

struct StretchingThumnailView:UIViewRepresentable{
    var videoid:String
    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView(frame: CGRect(x: 0, y: 0, width: 100, height: 60))
        view.layer.cornerRadius = 10
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let youtubeURL = URL(string: "https://img.youtube.com/vi/\(videoid)/maxresdefault.jpg") else{return}
        uiView.scrollView.isScrollEnabled = false
        uiView.load(URLRequest(url: youtubeURL))
    }
}
