//
//  GuidManager.swift
//  GuidanceDemo
//
//  Created by ldy on 17/3/20.
//  Copyright © 2017年 BJYN. All rights reserved.
//

import UIKit
import Aspects

//新手引导数据模型
class Guid: NSObject {
    var viewController:String = ""
    var guidImage:String = ""
    var isLongPage:Bool = false
    
    fileprivate var showed:Bool = false
}

//新手引导协议
@objc protocol GuidProtocol {
    
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
}

//新手引导信息加载器协议
protocol GuidLoaderProtocol {
    
    /// 配置文件路径
    var path:String {get set}

    /// 加载配置信息
    ///
    /// - returns: 配置信息
    func loadGuids()->[Guid]
}


//新手引导管理器
class GuidManager: NSObject {
    
    fileprivate var guids:[Guid] = [Guid]()
    fileprivate var guidLoader:GuidLoaderProtocol!
    
    static var defaultManager:GuidManager = GuidManager(loader: GuidPlistLoader())
    private init(loader:GuidLoaderProtocol) {
        guidLoader = loader
        //设置guid hook
        GuidManager.setGuidHook()
        //初始化Launch util
        let _ = LaunchUtil.share
    }
    
    @discardableResult
    func setConfigPath(path:String)->GuidManager{
        guidLoader.path = path
        guids = guidLoader.loadGuids()
        return self
    }
    
    fileprivate func getGuid(_ vc:UIViewController) -> Guid? {
        //根据vc匹配，获取guidance model
        let str:NSString = NSStringFromClass(type(of:vc)) as NSString
        let className:String? = str.components(separatedBy: ".").last
        if className != nil {
            return self.guids.filter({$0.viewController == className}).first
        }
        return nil
    }
}

extension GuidManager{

    class func setGuidHook(){
        let wrappedBlock:@convention(block) (AnyObject)->Void = {(info)->Void in
            let vc:UIViewController = info.instance() as! UIViewController
            //显示新手引导的代码
            let guid:Guid? = GuidManager.defaultManager.getGuid(vc)
            if guid != nil {
                //判断是否应该显示guid
                var shouldShow:Bool = true
                if vc is GuidProtocol && vc.responds(to: #selector(GuidProtocol.shouldShowGuid(_:))) {
                    //用户自定义判断条件
                    shouldShow = (vc as! GuidProtocol).shouldShowGuid(guid!)
                }else {
                    //默认判断条件
                    shouldShow = GuidManager.defaultShouldShowGuid(guid!)
                }
                if shouldShow == true {
                    if vc is GuidProtocol && vc.responds(to: #selector(GuidProtocol.showGuidImage(_:))) {
                        //具体类自定义实现
                        (vc as! GuidProtocol).showGuidImage(guid!)
                    }else {
                        //默认实现
                        if guid!.isLongPage {
                            //长页面
                            let scrollV:UIScrollView = UIScrollView(frame: UIScreen.main.bounds)
                            let imageView:UIImageView = UIImageView(frame: UIScreen.main.bounds)
                            let image:UIImage = UIImage(named: guid!.guidImage)!
                            imageView.image = image
                            let imageHeight:CGFloat = image.size.height
                            imageView.frame.size.height = imageHeight
                            scrollV.addSubview(imageView)
                            scrollV.contentSize.height = imageHeight
                            scrollV.bounces = false
                            scrollV.addGestureRecognizer(UITapGestureRecognizer(target: GuidManager.defaultManager, action: #selector(GuidManager.defaultManager.imageTapped(_:))))
                            GuidManager.setWindowHook(subView: scrollV)
                            
                        }else{
                            //短页面
                            let imageView:UIImageView = UIImageView(frame: UIScreen.main.bounds)
                            imageView.image = UIImage(named: guid!.guidImage)
                            imageView.isUserInteractionEnabled = true
                            imageView.addGestureRecognizer(UITapGestureRecognizer(target: GuidManager.defaultManager, action: #selector(GuidManager.defaultManager.imageTapped(_:))))
                            GuidManager.setWindowHook(subView: imageView)
                        }
                    }
                }
            }
        }
        do {
            try UIViewController.aspect_hook(#selector(UIViewController.viewDidLoad), with: AspectOptions.init(rawValue: 0), usingBlock: unsafeBitCast(wrappedBlock, to: AnyObject.self))
        }catch{
        }
    }
    
    fileprivate class func setWindowHook(subView:UIView){
        if let win = UIApplication.shared.keyWindow {  //window不为nil，直接添加subView
            win.addSubview(subView)
        }else {  //window为nil，监控UIWindow.makeKey方法执行后再添加subView
            let wrappedBlock:@convention(block) (AnyObject)->Void = {(info)->Void in
                let aspectInfo:AspectInfo = info as! AspectInfo
                let win = aspectInfo.instance() as! UIWindow
                win.addSubview(subView)
            }
            do {
                try UIWindow.aspect_hook(#selector(UIWindow.makeKey), with: AspectOptions.optionAutomaticRemoval, usingBlock: unsafeBitCast(wrappedBlock, to: AnyObject.self))
            }catch{
            }
        }
    }
    
    @objc fileprivate func imageTapped(_ sender:UIGestureRecognizer){
        sender.view?.removeFromSuperview()
    }
}

extension GuidManager{
    
    /// 是否显示引导的默认判断条件
    ///规则：应用第一次启动，且本次启动还没有进入过该页
    ///
    /// - parameter guid: 引导信息
    ///
    /// - returns: true or false
    class func defaultShouldShowGuid(_ guid:Guid)->Bool{
        if guid.showed == false && LaunchUtil.share.isFirstLaunch {
            guid.showed = true
            return true
        }
        return false
    }
}
