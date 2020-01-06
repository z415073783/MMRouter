//
//  UINavigationController+PushExtension.swift
//  MMRouter
//
//  Created by zlm on 2020/1/6.
//  Copyright © 2020 zlm. All rights reserved.
//

import Foundation
import UIKit
extension UINavigationController {
    
    func mm_pushViewController(_ viewController: UIViewController, animated: Bool) {
         //相同Controller不会重复打开
         if type(of: topViewController) != type(of: viewController) {
             viewController.hidesBottomBarWhenPushed = true
             pushViewController(viewController, animated: animated)
         }
     }

    
}
