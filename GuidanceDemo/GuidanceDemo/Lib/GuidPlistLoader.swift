//
//  GuidPlistLoader.swift
//  GuidanceDemo
//
//  Created by ldy on 17/3/20.
//  Copyright © 2017年 BJYN. All rights reserved.
//

import UIKit

class GuidPlistLoader: NSObject, GuidLoaderProtocol{
    var path:String = ""
    func loadGuids()->[Guid]{
        //读取plist文件，构建CCPGuidance数组
        var result:[Guid] = [Guid]()
        if let guidanceArray =  NSArray(contentsOfFile: path) {
            print(guidanceArray.description)
            for item in guidanceArray {
                let guidance:Guid = Guid()
                //将item转换为Guid类型
                let dic:NSDictionary = item as! NSDictionary
                guidance.viewController = dic.value(forKey: "ViewController") as! String
                guidance.guidImage = dic.value(forKey: "GuidanceImage") as! String
                if dic.value(forKey: "IsLongPage") != nil {
                    guidance.isLongPage = (dic.value(forKey: "IsLongPage") as! NSNumber).boolValue
                }
                result.append(guidance)
            }
        }
        return result
    }
}
