# TimCore
TimCore分为 core 核心布恩,和 TimJpush ,TimShare ,TimBaseViewModel ,TimAFAppConnectClient,几个子模块,子模块都可以独立使用,互不影响,
<h1>Timcore</h1>
<li>Timcore 为其他的 module 需要的基本支持部分,基于RAC 2.5实现,主要为 OC 版本提供支持,</li>
<li>TimJpush 简化推送的代码逻辑,这个使用的 jpush 作为拓展,只需要设置3方 sdk 的 key 和 一个 收到推送的 block 即可</li>
<li>TimShare 简化分享的代码逻辑,这个使用的  Sharesdk 作为拓展,只需要设置 各个3方 sdk 的 key 和 一个 分享成功的回调即可</li>
<li>TimBaseViewModel 实现基于 RAC 实现的 MVVM 网络请求方案,支持上传 key-value 数据,支持上传 图像等其他二进制数据, 返回数据支持重新处理之后才传递给下一级, 良好的支持列表数据返回,自带分页管理, 支持整体配置基本的网络访问参数,</li>
<li>TimAFAppConnectClient 基于 AF 3.0 做的一个简化网络请求的设置模块,支持 设置 基本的数据来过滤 非正常状态码的数据,简化大量网络请求的代码</li>





<h1>Timcore</h1>
<ul>
<li>Timcore 为其他的 module 需要的基本支持部分,基于RAC 2.5实现,主要为 OC 版本提供支持,</li>
<li>主要对外提供 TimCoreAppDelegate : UIResponder <UIApplicationDelegate>的基础类,其他子模块在需要的时候都会引入这个部分</li>

````objectivec
//定义
@interface TimCoreAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+(TimCoreAppDelegate*)shareInstance;

@end

///继承使用--推送部分
@interface  TimCoreAppDelegate (myJpush)
///code
@end
````


<h1>TimJpush</h1>
<ul>
<li>简化推送的代码逻辑,这个使用的 jpush 作为拓展,只需要设置3方 sdk 的 key 和 一个 收到推送的 block 即可</li>
<li>借鉴于 jiaAppDelegate 的,[jiaAppDelegate] , 不能忘记   [super application:application didFinishLaunchingWithOptions:launchOptions];
</li>
<li>借推送测试工具 <https://github.com/KnuffApp/Knuff></li>

````objectivec

+(void)load
{
[super load];
///设置极光的 push 方案
[TimJpushConfigManager sharedInstance].enableJpush = YES;
[TimJpushConfigManager sharedInstance].pushAppKey = @"XXXX";
[TimJpushConfigManager sharedInstance].apsForProduction = YES;
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
// Override point for customization after application launch.
///不能忘记
[super application:application didFinishLaunchingWithOptions:launchOptions];

__weak AppDelegate *weak_self =self;
self.pushBlock = ^(NSDictionary *userInfo, UIApplicationState state){
///do it by yourself
//STRONG_SELF

};


return YES;
}
````

<h4>亲爱的各位同行，如果你已经浏览到这，请帮我点下右上角星星Star，非常感谢</h4>
[jiaAppDelegate]: https://github.com/TimRabbit/TimCore.git





<h1>TimShare</h1>
<ul>
<li>简化分享的代码逻辑,这个使用的 sharesdk 作为拓展,只需要设置3方 sdk 的 key 和 一个 收到mob的 block 即可</li>
<li>因为 qq 的 sdk导致 pod lib lint 不通过,</li>

````objectivec
typedef void(^ShareResult)(BOOL sucess,NSString *msg);

@interface   AppDelegate(share)

-(void)initSharedSDK;

-(void)shareInfo:(NSString *)title content:(NSString *)content image:(id)image  url:(NSString *)url actionSheet:(UIView *)actionSheet onShareStateChanged:(ShareResult)shareStateChangedHandler;


@end
````



<h1>TimBaseViewModel</h1>
<ul>
<li>TimBaseViewModel 实现基于 RAC 实现的 MVVM 网络请求方案,支持上传 key-value 数据,支持上传 图像等其他二进制数据, 返回数据支持重新处理之后才传递给下一级, 良好的支持列表数据返回,自带分页管理, 支持整体配置基本的网络访问参数, </li>
````

-(void)initialize
{
    
    [super initialize];
    
    ///设置请求地址
    self.path = @"show-img/view";
    @weakify(self)
    ///处理上传数据
    self.inputBlock = ^(NSMutableDictionary *para ) {    
        @strongify(self)
        if (para && self. id     ) {
            [para setObject:self.id forKey:@"id"];
        }
        return para;
    };
    ///处理图片上传数据,  基于AF
    self.formDataInputBlock = ^(id <AFMultipartFormData>  _Nullable formData) {
       @strongify(self)    
        if (self.object.img) {
           NSInteger I =0 ;
            for (UIImage *image  in @[self.object.img] ) {
               NSData *data  = UIImagePNGRepresentation(image);
                if(data == nil){
                    data  = UIImageJPEGRepresentation(image,1);
                }
                if(data){
                  [formData appendPartWithFileData:data name:[NSString stringWithFormat:@"pic[%ld]",I++] fileName:@"pic.png"mimeType:@"image/png" ];
                }
            }
       }
    };
    
    ///非列表数据输出  
    self.outputBlock = ^(NSDictionary *para ) {
        @strongify(self)
        self.obj = [[XXXDetailObject  alloc]  mj_setKeyValues:para];
        return self.obj ;
    };

  ///列表数据输出  
     self.block = ^NSArray *(NSDictionary *dict){
        return  [xxxxObject   mj_objectArrayWithKeyValuesArray: dict   ];
    };
    
}
````




<h1>TimAFAppConnectClient</h1>
<ul>
<li>TimAFAppConnectClient 基于 AF 3.0 做的一个简化网络请求的设置模块,支持 设置 基本的数据来过滤 非正常状态码的数据,简化大量网络请求的代码</li>


````objectivec
///设置状态码等基本数据
-(void)setSucessCode:(NSInteger)sucessCode statusCodeKey:(NSString *_Nonnull)statusCodeKey msgKey:(NSString *_Nonnull)msgKey responseDataKey:(NSString * _Nonnull)responseDataKey;
    
    ///常见 post 请求
    /**
 *  POST请求
 *
 *  @param methodName    方法名
 *  @param param         参数
 *  @param checkNullData 检查data是否为空
 *  @param successBlock  成功回调
 *  @param failedBlock   失败回调
 */
- (void)skPostWithMethodName:(NSString *_Nonnull)methodName
                       param:(NSDictionary * _Nullable )param
               checkNullData:(BOOL)checkNullData
                successBlock:(void(^_Nullable)(NSURLSessionDataTask * _Nonnull task, id _Nullable json))successBlock
                 failedBlock:(void(^_Nullable)(NSURLSessionDataTask * _Nonnull task, id _Nullable json, SKErrorMsgType errorType, NSError *_Nullable error))failedBlock;
````


