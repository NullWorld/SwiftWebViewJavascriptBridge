SwiftWebViewJavascriptBridge

swift webview javasriptBrige 现在仅支持swift wkwebview 用于和h5交互。 此库完全按照oc 版 webviewjavascriptbridge 如果要使用oc 版请移步 ->>>>>https://github.com/marcuswestin/WebViewJavascriptBridge

直接导入包 用法和oc版本完全一样。

创建桥接对象 bridge = SwiftJavascriptBridge.bridgeForWebView(webView: webview)   服从协议 bridge?._webViewDelegate = self

然后注册就可以接H5发送给原生的数据 bridge?.registerHandler(handerName: "webview_call_native", handler: { (data, responseCallback:WVJBResponseCallback) in WCLog(message: data) })

发送数据给H5直接调用 self.bridge?.callHandler(handlerName: "native_call_webview", data: "{"param":{"typeId":"10122","starttime":"2017-11-02","endtime":"2017-11-04"}}")

#评驾APP 代码规范
一、类的代码结构
1. ViewController的代码结构
#pragma mark - Life Cycle Methods
- (instancetype)init

#pragma mark - Override Methods

#pragma mark - Intial Methods

#pragma mark - Network Methods

#pragma mark - Target Methods

#pragma mark - Public Methods

#pragma mark - Private Methods

#pragma mark - UITableViewDataSource  
#pragma mark - UITableViewDelegate  

#pragma mark - Lazy Loads

#pragma mark - NSCopying  

#pragma mark - NSObject  Methods

- (void)viewWillAppear:(BOOL)animated
- (void)viewDidAppear:(BOOL)animated
- (void)viewWillDisappear:(BOOL)animated
- (void)viewDidDisappear:(BOOL)animated
- (void)dealloc

2. Cell的代码结构
#import <UIKit/UIKit.h>


@class PPBillTypeView;
#pragma 协议声明
@protocol PPBillTypeViewDelegate <NSObject>
#pragma 协议方法
@optional
- (void)billTypeView:(PPBillTypeView *)typeView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface PPBillTypeView : UIView
#pragma 代理
@property (nonatomic,weak) id <PPBillTypeViewDelegate>delegate;
@property (nonatomic,strong,readonly)NSIndexPath *selectedIndex;

#pragma 初始化方法
- (instancetype)initWithFrame:(CGRect)frame typeArray:(NSArray *)array;

#pragma 公有方法
- (void)show;

@end



















