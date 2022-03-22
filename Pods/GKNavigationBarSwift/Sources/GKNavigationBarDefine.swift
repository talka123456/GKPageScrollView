//
//  GKNavigationBarDefine.swift
//  GKNavigationBarSwift
//
//  Created by QuintGao on 2020/3/24.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit

public let GK_SCREEN_WIDTH = UIScreen.main.bounds.size.width
public let GK_SCREEN_HEIGHT = UIScreen.main.bounds.size.height

/// 导航栏间距，用于不同控制器之间的间距
public let GKNavigationBarItemSpace: CGFloat = -1.0

public enum GKNavigationBarBackStyle {
    case none
    case black
    case white
}

public func gk_swizzled_instanceMethod(_ prefix: String, oldClass: Swift.AnyClass!, oldSelector: String, newClass: Swift.AnyClass) {
    let newSelector = prefix + "_" + oldSelector;
    
    let originalSelector = NSSelectorFromString(oldSelector)
    let swizzledSelector = NSSelectorFromString(newSelector)
    
    let originalMethod = class_getInstanceMethod(oldClass, originalSelector)
    let swizzledMethod = class_getInstanceMethod(newClass, swizzledSelector)
    
    let isAdd = class_addMethod(oldClass, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
    
    if isAdd {
        class_replaceMethod(newClass, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
    }else {
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
}

// 定义Awake协议，让需要重新系统方法的类实现该协议
public protocol GKObjectAwakeProtocol: AnyObject {
    static func gkObjectAwake()
}

public protocol GKAwakeProtocol: AnyObject {
    static func gkAwake()
}

public protocol GKChildAwakeProtocol: AnyObject {
    static func gkChildAwake()
}

public protocol GKGestureAwakeProtocol: AnyObject {
    static func gkGestureAwake()
}

public protocol GKGestureChildAwakeProtocol: AnyObject {
    static func gkGestureChildAwake()
}

class NothingToSeeHere {
    static func harmlessFunction() {
        UIViewController.gkAwake()
        UINavigationController.gkChildAwake()
        UINavigationItem.gkAwake()
        NSObject.gkObjectAwake()
        UIScrollView.gkAwake()
        UIViewController.gkGestureAwake()
        UINavigationController.gkGestureAwake()
    }
}

// 让APP启动时只执行一次harmlessFunction 方法
extension UIApplication {
    private static let runOnce: Void = { // 使用静态属性以保证只调用一次(该属性是个方法)
        NothingToSeeHere.harmlessFunction()
    }()

    open override var next: UIResponder? { // 重新next属性
        UIApplication.runOnce
        return super.next
    }
}

// MARK: - Swizzling会改变全局状态，所以用DispatchQueue.once来确保无论多少线程都只会被执行一次
extension DispatchQueue {
    private static var onceTracker = [String]()
    // Executes a block of code, associated with a unique token, only once.  The code is thread safe and will only execute the code once even in the presence of multithreaded calls.
    public class func once(token: String, block: () -> Void) {
        // 保证被 objc_sync_enter 和 objc_sync_exit 包裹的代码可以有序同步地执行
        objc_sync_enter(self)
        defer { // 作用域结束后执行defer中的代码
            objc_sync_exit(self)
        }
        
        if onceTracker.contains(token) {
            return
        }
        
        onceTracker.append(token)
        block()
    }
}
