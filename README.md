# Guidance
## 简介
Guidance帮助开发者快速实现页面使用引导信息的显示，提供了一套默认实现供开发者使用，同时也支持开发者自定义是否显示引导的条件，以及自定义如何显示引导图。支持超出屏幕高度的长引导页面。若使用默认实现，开发者只需两步即可给App添加引导功能：
* 按照指定格式，在plist文件中配置页面和引导图片信息
* 在AppDelegate的didFinishLaunchingWithOptions方法中给Guidance设置配置文件路径
## 结构
*  **GuidManager**
引导管理类，是Guidance的核心类，负责配置管理、设置hook、显示规则判断。
* **GuidProtocol**
引导协议，提供开发者`自定义是否显示引导的条件` 和 `自定义如何显示引导` 的方法。
开发者如果不想使用提供的默认实现，则可以让ViewController实现该协议并提供自定义实现

```Swift
/// 是否应该显示引导
///
/// - parameter guid: 引导信息
///
/// - returns: true or false
@objc func shouldShowGuid(_ guid:Guid) ->Bool

/// 自定义如何显示引导
///
/// - parameter guid: 引导信息
///
/// - returns: true or false
@objc func showGuidImage(_ guid:Guid) -> Void
```
> ##### 默认实现
> ###### 是否显示引导的条件：应为为第一次启动，且本次启动还未进入过该页面，则显示引导，否则不显示
> ###### 引导显示样式：窗体顶层显示引导图，点击引导图则移除；长引导图可上下滑动，点击引导图则移除

* **GuidLoaderProtocol**
配置文件加载器协议，如果开发者不想使用plist文件存储配置信息，或者想自定义plist文件格式，则可以自定义配置文件加载器，并实现该协议。协议内容如下：
```swift
/// 配置文件路径
var path:String {get set}

/// 加载配置信息
///
/// - returns: 配置信息
func loadGuids()->[Guid]
```
* **GuidPlistLoader**
默认的plist配置文件信息加载类，负责加载plist文件信息（开发者不会直接使用到该类）

## 使用说明
### 将Guidance添加到工程
* 下载Guidance，并直接将Guidance文件夹添加到工程
* Guidance使用了Aspects第三方工具，所以需要将Aspects引入到工程，引入方法见[Aspects](https://github.com/steipete/Aspects)
### 添加plist文件并填写配置信息
plist格式如下所示：
![Alt text](./QQ20170320-152237.png)
* **ViewController **：页面控制器类名称
* **GuidanceImage**：要显示的引导图图片名称
* **IsLongPage**：是否是长引导图，若引导图超出屏幕高度需要上下滑动，则需要设置为true
### 将plist文件路径赋值给GuidManager
在AppDelegate的didFinishLaunchingWithOptions方法中调用GuidManager的setConfigPath方法来设置配置文件路径

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    GuidManager.defaultManager.setConfigPath(path: Bundle.main.path(forResource: "Guidance", ofType: "plist")!)
    return true
}
```
