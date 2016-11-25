# TimCore
TimCore分为 core,TimJpush ,TimShare 


<h1>Timcore</h1>
<li>Timcore 为其他的 module 需要的基本支持部分 </li>






<h1>TimJpush</h1>
<ul>
<li>简化推送的代码逻辑,这个使用的 jpush 作为拓展,只需要设置3方 sdk 的 key 和 一个 收到推送的 block 即可</li>
<li>借鉴于 jiaAppDelegate 的,[jiaAppDelegate]</li>
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

