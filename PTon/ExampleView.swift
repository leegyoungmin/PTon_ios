//
//  ExampleView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/30.
//

import Foundation
import WebKit
import SwiftUI

struct ExampleView:UIViewRepresentable{
    func makeUIView(context: Context) -> WKWebView {
        let preference = WKPreferences()
        preference.javaScriptCanOpenWindowsAutomatically = false
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preference
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        webView.scrollView.isScrollEnabled = false
        
        let url = Bundle.main.url(forResource: "Example", withExtension: "html")!
        print("Url in ExampleView ::: \(url)")
        let request = URLRequest(url: url)
        print("request in Example View ::: \(request)")
        webView.load(request)
        
        webView.evaluateJavaScript("setting()") { result, error in
            print(error)
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator : WKScriptMessage, WKNavigationDelegate{
        var parent:ExampleView
        
        init(_ uiWebView:ExampleView){
            self.parent = uiWebView
        }
        
        // 기본 프레임에서 탐색이 시작되었음
        func webView(_ webView: WKWebView,
                     didStartProvisionalNavigation navigation: WKNavigation!) {
            print("기본 프레임에서 탐색이 시작되었음")
        }
        
        // 웹보기가 기본 프레임에 대한 내용을 수신하기 시작했음
        func webView(_ webView: WKWebView,
                     didCommit navigation: WKNavigation!) {
            print("내용을 수신하기 시작");
        }
        
        // 탐색이 완료 되었음
        func webView(_ webview: WKWebView,
                     didFinish: WKNavigation!) {
            print("탐색이 완료")
        }
        
        // 초기 탐색 프로세스 중에 오류가 발생했음 - Error Handler
        func webView(_ webView: WKWebView,
                     didFailProvisionalNavigation: WKNavigation!,
                     withError: Error) {
            print("초기 탐색 프로세스 중에 오류가 발생했음")
            print(withError.localizedDescription)
        }
        
        // 탐색 중에 오류가 발생했음 - Error Handler
        func webView(_ webView: WKWebView,
                     didFail navigation: WKNavigation!,
                     withError error: Error) {
            print("탐색 중에 오류가 발생했음")
            print(error.localizedDescription)
        }
    }
}
