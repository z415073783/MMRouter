//
//  MMRouter.swift
//  MMRouter
//
//  Created by zlm on 2020/1/6.
//  Copyright © 2020 zlm. All rights reserved.
//


import Foundation
//import MMBaseFramework
extension String {
    func mm_split(_ separator: Character) -> [String] {
        return self.split { $0 == separator }.map(String.init)
    }
}

extension DispatchSemaphore {
    @discardableResult
    func mm_wait(_ timeoutMillisecond: Int,
                 functionName: String = #function,
                 fileName: String = #file,
                 lineNumber: Int = #line) -> DispatchTimeoutResult {
        let result = wait(timeout: DispatchTime.now() + .milliseconds(timeoutMillisecond))
        if result == .timedOut {
            let lastFileName = fileName.mm_split(".").last ?? ""
            let callInfo = "[\(lastFileName):\(functionName):\(lineNumber)]"
            print(callInfo)
        }
        return result
    }
}

//import MMBaseFramework
@objc public class MMRouter: NSObject {
    static let shared = MMRouter()
    private var registerMap: [String: [MMRouterModel]] = [:]
    let queue: OperationQueue = {
        let _queue = OperationQueue()
        _queue.maxConcurrentOperationCount = 1
        _queue.name = "MMRouterQueue"
        return _queue
    }()

    private func setRegisterValue(model: MMRouterModel) {
        let semaphore = DispatchSemaphore(value: 0)
        queue.addOperation { [weak self] in
            guard let `self` = self else { return }
            
            if var list = self.registerMap[model.key] {
                list.append(model)
                self.registerMap[model.key] = list
            } else {
                self.registerMap[model.key] = [model]
            }
            semaphore.signal()
        }
        let result = semaphore.mm_wait(1000)
        if result == .timedOut {
            print("设置连接超时 model = \(model)")
        }
    }
    private func getRegisterValue(key: String) ->[MMRouterModel]? {
        let semaphore = DispatchSemaphore(value: 0)
        var modelList: [MMRouterModel]?
        queue.addOperation {
            modelList = MMRouter.shared.registerMap[key]
            semaphore.signal()
        }
        let result = semaphore.mm_wait(1000)
        if result == .timedOut {
            print("获取连接超时 key = \(key)")
        }
        return modelList
    }

}
fileprivate typealias Unregister = MMRouter
@objc public extension Unregister {

    //移除指定target的单个注册事件
    class func unregister(target: NSObject, key: String, finishBlock: (() ->Void)? = nil) {
        shared.queue.addOperation {
            let targetAddress = target.getAddressIdentifity()
            if var modelList = MMRouter.shared.registerMap[key] {
                var isChange = false
                for i in (0 ..< modelList.count).reversed() {
                    let model = modelList[i]
                    if model.target?.getAddressIdentifity() == targetAddress {
                        modelList.remove(at: i)
                        isChange = true
                    }
                }
                if isChange {
                    if modelList.count == 0 {
                        MMRouter.shared.registerMap[key] = nil
                    } else {
                        MMRouter.shared.registerMap[key] = modelList
                    }
                }
            }
            
            if let block = finishBlock {
                block()
            }
        }
    }
    
    /// 根据key值移除所有注册事件
    ///
    /// - Parameters:
    ///   - key:
    ///   - finishBlock:
    class func unregister(key: String, finishBlock: (() ->Void)? = nil) {
        shared.queue.addOperation {
            MMRouter.shared.registerMap[key] = nil
            if let block = finishBlock {
                block()
            }
        }
    }

    /// 移除指定target的所有注册数据
    ///
    /// - Parameters:
    ///   - target: target
    ///   - finishBlock:
    class func unregister(target: NSObject, finishBlock: (() ->Void)? = nil) {
        shared.queue.addOperation {
            let targetAddress = target.getAddressIdentifity()
            for (key, modelList) in MMRouter.shared.registerMap {
                var mutiModelList = modelList
                var isChange = false
                for i in (0 ..< modelList.count).reversed() {
                    let model = modelList[i]
                    if model.target?.getAddressIdentifity() == targetAddress {
                        mutiModelList.remove(at: i)
                        isChange = true
                    }
                }
                if isChange {
                    if mutiModelList.count == 0 {
                        MMRouter.shared.registerMap[key] = nil
                    } else {
                        MMRouter.shared.registerMap[key] = mutiModelList
                    }
                }
            }
            if let block = finishBlock {
                block()
            }
        }
    }
}
fileprivate typealias Register = MMRouter
@objc public extension Register {
    /// 注册 基本方法
    ///
    /// - Parameter model:
    class func register(model: MMRouterModel) {
        shared.setRegisterValue(model: model)
    }

    /// 注册 无回调
    ///
    /// - Parameters:
    ///   - target: 注册方实例
    ///   - key: key值, 需要项目唯一,模块内注册需要添加模块名称前缀以避免冲突
    ///   - block:  实现block
    class func registerB(target: NSObject, key: String, block: @escaping () ->Void) {
        let model = MMRouterModel(target: target, key: key) { (_, _) in
            block()
        }
        register(model: model)
    }

    /// 注册 带参数
    ///
    /// - Parameters:
    ///   - target: 注册方实例
    ///   - key: key值, 需要项目唯一,模块内注册需要添加模块名称前缀以避免冲突
    ///   - block: 实现block,带参数传递
    class func registerC(target: NSObject, key: String, block: @escaping (_ params: Any?) ->Void) {
        let model = MMRouterModel(target: target, key: key) { (sender, _) in
            block(sender)
        }
        register(model: model)
    }

    /// 注册 带参数和回调block
    /// - Parameters:
    ///   - target: 注册方实例
    ///   - key: key值, 需要项目唯一,模块内注册需要添加模块名称前缀以避免冲突
    ///   - block: 实现block 带参数传递和完成回调block, 可在调用方发起block, 注册方接收block
    class func register(target: NSObject, key: String, block: ((_ params: Any?, _ finishBlock: ((_ params: Any?) -> Void)?) ->Void)?) {
        register(model: MMRouterModel(target: target, key: key, handler: block))
    }

}
fileprivate typealias CallMethod = MMRouter
@objc public extension CallMethod {
    /// 打开action
    ///
    /// - Parameters:
    ///   - key: key
    ///   - params: 传入参数
    ///   - finishBlock: 服务方的回调block
    /// - Returns: 是否正常调用接口
    @discardableResult class func callMethod(key: String, params: Any? = nil, finishBlock: ((_ params: Any?) ->Void)? = nil) -> Bool {
        guard let modelList = shared.getRegisterValue(key: key) else {
            return false
        }

        for model in modelList {
            if let block = model.handler {
                if model.target == nil {
                    //TODO: 只移除单个
//                    unregister(key: key) //target对象已销毁,不再监听该注册事件
                }
                block(params, finishBlock)
            }
        }
        return true
    }

    /// 使用url方式传参
    ///
    /// - Parameters:
    ///   - url: url 例: "http://userData?param1=这是参数1&param2=这是参数2" ,"http://userData"做为key值进行匹配, 符号"?"后面为参数,以Array形式保存
    ///   - finishBlock: 完成回调
    /// - Returns: 是否正常调用接口
    class func openURL(url: String, finishBlock: ((_ params: Any?) ->Void)? = nil) -> Bool {
        let list = url.mm_split("?")
        guard let key = list.first else {
            return false
        }
//        var params: String?
        var dic: [String: String] = [:]
        if list.count == 2, let last = list.last {
            let params = last.mm_split("&")
            for item in params {
                let keyValue = item.mm_split("=")
                if let key = keyValue.first, let value = keyValue.last {
                    dic[key] = value
                }
            }
        } else if list.count > 2 {
            print("[MMRouter] url格式错误,不能有多个'?'")

            return false
        }
        guard let modelList = shared.getRegisterValue(key: key) else {
            return false
        }
        for model in modelList {
            if let block = model.handler {
                if model.target == nil {
                    //TODO: 只移除单个
//                    unregister(key: key) //target对象已销毁,不再监听该注册事件
                }
                block(dic, finishBlock)
            }
        }
        
        return true
    }

}
