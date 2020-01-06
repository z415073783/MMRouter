//
//  NSObject+Extension.swift
//  MMRouter
//
//  Created by zlm on 2020/1/6.
//  Copyright © 2020 zlm. All rights reserved.
//

import Foundation
extension NSObject {
    /// 获取对象实例的id，类似指针
     ///
     /// - Returns: 对象实例的id
    func getAddressIdentifity() -> String {
         let address: CVarArg = self as CVarArg
         let targetDes = String(format: "%018p", address)
         return targetDes
     }
}
