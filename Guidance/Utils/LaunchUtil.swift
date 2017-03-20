//
//  LaunchUtil.swift
//  CodeLibrary
//
//  Created by ldy on 16/7/29.
//  Copyright © 2016年 YNKJMACMINI2. All rights reserved.
//

import UIKit
import Aspects

let LaunchUserDefaultKeySuffix = "HadLaunched"

//标识是否为第一次启动的标志管理
class LaunchUtil: NSObject {
    
    static var share:LaunchUtil = LaunchUtil()
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(self.appDidEnterBackground(notify:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    //判断是否为第一次启动
    var isFirstLaunch:Bool {
        get{
            let launchUserDefaultKey = self.getLaunchUserDefaultKey()
            let hadLaunched:Bool = UserDefaults.standard.bool(forKey: launchUserDefaultKey)
            if hadLaunched == false {
                return true
            }
            else{
                return false
            }
        }
    }
    
    //MARK:- private
    //构建UserDefaultKey：Version + . + Build + LaunchUserDefaultKeySuffix
    //使用版本号作为键值，保证每次安装新版本后启动时，均为第一次启动
    private func getLaunchUserDefaultKey() -> String {
        //Version
        let version:String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        //Build
        let buildVersion:String = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        return version + "." + buildVersion + LaunchUserDefaultKeySuffix
    }
    
    @objc private func appDidEnterBackground(notify:Notification){
        UserDefaults.standard.set(true, forKey: self.getLaunchUserDefaultKey())
    }
}
