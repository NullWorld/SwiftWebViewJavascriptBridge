//
//  SwiftJavascriptBridge.swift
//  SwiftWebViewJavascriptBridge
//
//  Created by cy on 2017/10/18.
//  Copyright © 2017年 Cy. All rights reserved.
//

import UIKit
import WebKit

//typealias
//    WVJBResponseCallback = (_ responseData:AnyObject)->(AnyObject)

class SwiftJavascriptBridge: NSObject,WKNavigationDelegate,SwiftJavascriptBridgeBaseDelegate {
    
    weak var _webView:WKWebView? = nil
    weak var _webViewDelegate:WKNavigationDelegate? = nil
    let _uniqueId:CUnsignedLong = 0
    var _base:SwiftJavascriptBridgeBase? = nil
    
    class func bridgeForWebView(webView:WKWebView)->SwiftJavascriptBridge{
        let bridge = SwiftJavascriptBridge.init()
        bridge._setupInstance(webView: webView)
        bridge.reset()
        return bridge
        
    }
    
    /**主要用两个方法，接受webview传给natvie的值*/
    func registerHandler(handerName:String,handler:@escaping WVJBHandler){
        _base?.messageHandlers?[handerName] = handler
    }
    
    
    /**主要用两个方法，接受native传给webview的值*/
    
    func callHandler(handlerName:String,data:Any){
        
        
        let callBack:WVJBResponseCallback = {(id:Any) in
            
        }
        
        self.callHandler(handlerName: handlerName, data: data, responseCallback:callBack)
    }
    
    func callHandler(handlerName:String,data:Any,responseCallback:@escaping WVJBResponseCallback){
        _base?.sendData(data: data, responseCallback: responseCallback, handlerName: handlerName)
    }
    
    

    func _setupInstance(webView:WKWebView){
        _webView = webView
        _webView?.navigationDelegate = self
        _base = SwiftJavascriptBridgeBase.init()
        _base?.delegate = self
        
    }
    
    func WKFlushMessageQueue(){
        _webView?.evaluateJavaScript((_base?.webViewJavascriptFetchQueyCommand())!, completionHandler: { (result, error) in
            if error != nil {
                print("WebViewJavascriptBridge: WARNING: Error when trying to fetch data from WKWebView: \(error)")
            }
            self._base?.flushMessageQueue(messageQueueString: result as! String)
        })
    }
    

    
    func reset(){
        _base?.reset()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if _webView != webView { return }
        _webViewDelegate?.webView!(webView, didFinish: navigation)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if _webView != webView { return }
        if (_webViewDelegate != nil) {
            _webViewDelegate?.webView!(webView, decidePolicyFor: navigationResponse, decisionHandler:decisionHandler)
        }else{
            decisionHandler(.allow)
        }
    }
    
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if _webView != webView { return }
        if (_webViewDelegate != nil) {
            _webViewDelegate?.webView!(webView, didReceive: challenge, completionHandler: completionHandler)
        }else{
            completionHandler(.performDefaultHandling,nil)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if _webView != webView { return }
        let url:URL = navigationAction.request.url!
    
        
        if  (_base?.isWebViewJavascriptBridgeURL(url: url))! {
            
            if (_base?.isBridgeLoadedURL(url: url))! {
                _base?.injectJavascriptFile()
            }else if (_base?.isQueueMessageURL(url: url))! {
                self.WKFlushMessageQueue()
            }else{
                _base?.logUnkownMessage(url: url)
            }
            decisionHandler(.cancel)
        }
        
        if (_webViewDelegate != nil) {
            _webViewDelegate?.webView!(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
        }else{
            decisionHandler(.allow)
        }
    }


    func _evaluateJavascript(javascriptCommand: String)->String {
        
        _webView?.evaluateJavaScript(javascriptCommand, completionHandler: { (data, error) in
            print("--\(data)--\(error)---")
        })
        return ""
    }
    
    deinit {
        _base = nil;
        _webView = nil;
        _webViewDelegate = nil;
        _webViewDelegate = nil
    }
    
}


