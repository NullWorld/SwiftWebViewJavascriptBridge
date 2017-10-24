//
//  SwiftJavascriptBridgeBase.swift
//  SwiftWebViewJavascriptBridge
//
//  Created by cy on 2017/10/18.
//  Copyright © 2017年 Cy. All rights reserved.
//

import UIKit

@objc protocol SwiftJavascriptBridgeBaseDelegate {
    
   @objc optional func method()
    
    func _evaluateJavascript(javascriptCommand:String)->String
}

class SwiftJavascriptBridgeBase: NSObject,SwiftJavascriptBridgeBaseDelegate {
    
    var startupMessageQueue:NSMutableArray? = nil
    var responseCallbacks:NSMutableDictionary? = nil
    var messageHandlers : NSMutableDictionary? = nil
    var _uniqueId = 0
    
    
    override init() {
        super.init()
        messageHandlers = NSMutableDictionary.init()
        startupMessageQueue = NSMutableArray.init()
        responseCallbacks = NSMutableDictionary.init()
        _uniqueId = 0;
    }
   
    
    open var delegate:SwiftJavascriptBridgeBaseDelegate?
    
    
    internal func _evaluateJavascript(javascriptCommand: String)->String {
       let _ =  delegate?._evaluateJavascript(javascriptCommand: javascriptCommand)
        return ""
    }

    
    func sendData(data:Any,responseCallback:@escaping WVJBResponseCallback,handlerName:String){
        let message = NSMutableDictionary.init()
        
        message["data"]=data
        
        if responseCallback != nil  {
//            _uniqueId += 1
//            let callbackId:String = "objc_cb_"+String(_uniqueId)
//            responseCallbacks?[callbackId] = responseCallback
//            message["callbackId"] = callbackId
        }
        
        if handlerName != nil {
            message["handlerName"] = handlerName
        }
        self._queueMessage(message: message)
    }

    
    func reset(){
        startupMessageQueue = NSMutableArray.init()
        responseCallbacks = NSMutableDictionary.init()
        _uniqueId = 0
    }
    
    class func enableLogging(){
        logging = true;
    }
    
    
    func injectJavascriptFile(){
       let _ =  self._evaluateJavascript(javascriptCommand: WebViewJavascriptBridge_js())
        
        if (startupMessageQueue != nil) {
            let queue:NSArray = startupMessageQueue!
            startupMessageQueue = Optional.none
            for queueMsg in queue {
                self._dispatchMessage(message: queueMsg as! Dictionary<String, Any>)
            }
            
        }
    }
    
    
    func _queueMessage(message:WVJBMessage){
        if startupMessageQueue != nil {
            self.startupMessageQueue?.add(message)
        }else{
            self._dispatchMessage(message: message as! Dictionary<String, Any>)
        }
    }
    
    
    
    
    
    func _dispatchMessage(message:Dictionary<String, Any>){
        var messageJSON = self._serializeMessage(message: message, pretty: false)
        self._log(action: "SEND", json: messageJSON as AnyObject)
        
        print(messageJSON)
        
        messageJSON = messageJSON.replacingOccurrences(of: "\\", with: "\\\\")
        messageJSON = messageJSON.replacingOccurrences(of: "\"", with: "\\\"")
        messageJSON = messageJSON.replacingOccurrences(of: "\'", with: "\\\'")
        messageJSON = messageJSON.replacingOccurrences(of: "\n", with: "\\n")
        messageJSON = messageJSON.replacingOccurrences(of: "\r", with: "\\r")
        messageJSON = messageJSON.replacingOccurrences(of: "\\f", with: "\\f")
        messageJSON = messageJSON.replacingOccurrences(of: "\\u2028", with: "\\\\u2028")
        messageJSON = messageJSON.replacingOccurrences(of: "\\u2029", with: "\\\\u2029")
        
        print(messageJSON)
        
        
        
        let javascriptCommand = "WebViewJavascriptBridge._handleMessageFromObjC('\(messageJSON)');"
        
        if Thread.isMainThread {
           let _ = self._evaluateJavascript(javascriptCommand: javascriptCommand)
        }else{
            DispatchQueue.main.async {
            let _ =   self._evaluateJavascript(javascriptCommand: javascriptCommand)
            }
        }

    }
    
    func _serializeMessage(message:Any,pretty:Bool) -> String{
        
        var data:Data?
        
        if pretty {
            data =  try! JSONSerialization.data(withJSONObject:  message, options: .prettyPrinted)
        }else{
            data =  try! JSONSerialization.data(withJSONObject:  message, options: JSONSerialization.WritingOptions(rawValue: 0))
        }
        
        return String.init(data: data!, encoding: .utf8)!
    }
    
    //是否是桥架的url
    func isWebViewJavascriptBridgeURL(url:URL) -> Bool {
        if !self.isSchemeMatch(url: url) {
            return false
        }
        return self.isBridgeLoadedURL(url: url) || self.isQueueMessageURL(url: url)
    }
    
    func isSchemeMatch(url:URL) ->  Bool {
        let scheme = url.scheme?.lowercased()
        return (scheme == kNewProtocolScheme) || (scheme == kOldProtocolScheme)
    }
    
    func isQueueMessageURL(url:URL) ->  Bool {
        if kQueueHasMessage==url.host {
            return true
        }else{
            return false
        }
    }
    
    func isBridgeLoadedURL(url:URL) ->  Bool {
        let host = url.host?.lowercased()
        return self.isSchemeMatch(url: url) && (host == kBridgeLoaded)
    }
    
    func logUnkownMessage(url:URL){
        print("WebViewJavascriptBridge: WARNING: Received unknown WebViewJavascriptBridge command \(url.absoluteString)")
    }

    func webViewJavascriptCheckCommand() -> String{
        return "typeof WebViewJavascriptBridge == \'object\';"
    }
    
    func webViewJavascriptFetchQueyCommand() -> String{
        return "WebViewJavascriptBridge._fetchQueue();"
    }
    
    func _log(action:String,json:AnyObject){
        if !logging {return;}
        let json = self._serializeMessage(message: json, pretty: true)
        
        print("WVJB\(action):\(json)")
    }
    
    
    
    func flushMessageQueue(messageQueueString:String){
        if messageQueueString.isEmpty || messageQueueString.lengthOfBytes(using: .utf8)==0 {
            print("WebViewJavascriptBridge: WARNING: ObjC got nil while fetching the message queue JSON from webview. This can happen if the WebViewJavascriptBridge JS is not currently present in the webview, e.g if the webview just loaded a new page.")
            return
        }
        
        let messages:Array<NSDictionary> = self._deserializeMessageJSON(messageJSON: messageQueueString)
        
        for message in messages {
            if  message.isKind(of: NSDictionary.self) {
                 print("WebViewJavascriptBridge: WARNING: Invalid \(message) received: \(message.superclass)")
                
            }
            
            self._log(action: "RCVD", json: message)
            
            
            let responseId = message.object(forKey: "responseId")
            
            
            if responseId != nil{
                let responseCallback:WVJBResponseCallback = responseCallbacks?.object(forKey: responseId!) as! WVJBResponseCallback
                responseCallback(message.object(forKey: "responseData") as AnyObject)
                
                responseCallbacks?.removeObject(forKey: responseId!)
            }else{
                
               
                
                var responseCallback:WVJBResponseCallback?
                let callbackId = message.object(forKey: "callbackId")
                
                
                if  callbackId != nil {
                    
                    responseCallback = {(responseData:AnyObject) in
                        
                        let msg:WVJBMessage = ["responseId":callbackId!,"responseData":responseData]
                        self._queueMessage(message: msg)
                    }
                }else{
                    responseCallback = {(responseData:AnyObject) in
                        //do nothing
                    }
                }
                
                
                
                let handler:WVJBHandler = messageHandlers!.object(forKey: message.object(forKey: "handlerName")!) as! WVJBHandler
                if handler != nil {
                    print("WVJBNoHandlerException, No handler for message from JS: \(message)")
                }
                
                
                handler(message.object(forKey: "data") as AnyObject,responseCallback!)
                
            }
            
        }
    }
    
    func _deserializeMessageJSON(messageJSON:String)->Array<NSDictionary>{
        return try! JSONSerialization.jsonObject(with:messageJSON.data(using: .utf8)!, options: .allowFragments) as! Array
    }
    
    deinit{
        self.startupMessageQueue = nil
        self.responseCallbacks = nil
        self.messageHandlers = nil
    }
}
