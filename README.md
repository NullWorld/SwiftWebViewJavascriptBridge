SwiftWebViewJavascriptBridge

swift webview javasriptBrige 现在仅支持swift wkwebview 用于和h5交互。 此库完全按照oc 版 webviewjavascriptbridge 如果要使用oc 版请移步 ->>>>>https://github.com/marcuswestin/WebViewJavascriptBridge

直接导入包 用法和oc版本完全一样。

创建桥接对象 bridge = SwiftJavascriptBridge.bridgeForWebView(webView: webview)   服从协议 bridge?._webViewDelegate = self

然后注册就可以接H5发送给原生的数据 bridge?.registerHandler(handerName: "webview_call_native", handler: { (data, responseCallback:WVJBResponseCallback) in WCLog(message: data) })

发送数据给H5直接调用 self.bridge?.callHandler(handlerName: "native_call_webview", data: "{"param":{"typeId":"10122","starttime":"2017-11-02","endtime":"2017-11-04"}}")