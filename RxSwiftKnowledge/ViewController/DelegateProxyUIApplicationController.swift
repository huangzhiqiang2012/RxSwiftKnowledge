//
//  DelegateProxyUIApplicationController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/3/11.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class RxUIApplicationDelegateProxy: DelegateProxy<UIApplication, UIApplicationDelegate>, UIApplicationDelegate, DelegateProxyType {
    
    public weak private (set) var application: UIApplication?
    
    init(application: ParentObject) {
        self.application = application
        super.init(parentObject: application, delegateProxy: RxUIApplicationDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxUIApplicationDelegateProxy(application: $0) }
    }
    
    static func currentDelegate(for object: UIApplication) -> UIApplicationDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: UIApplicationDelegate?, to object: UIApplication) {
        object.delegate = delegate
    }
    
    override func setForwardToDelegate(_ delegate: UIApplicationDelegate?, retainDelegate: Bool) {
        super.setForwardToDelegate(delegate, retainDelegate: true)
    }
}

/// 自定义应用状态枚举
/// 不使用系统自带的的 UIApplicationState 是因为后者没有 terminated（终止）这个状态。
enum AppState {
    case active
    case inactive
    case background
    case terminated
}

extension UIApplication.State {
    
    /// 将其转为我们自定义的应用状态枚举
    func toAppState() -> AppState {
        switch self {
        case .active:
            return .active
        case .inactive:
            return .inactive
        case .background:
            return .background
        }
    }
}

extension Reactive where Base: UIApplication {
    
    /// 代理委托
    var delegate: DelegateProxy<UIApplication, UIApplicationDelegate> {
        return RxUIApplicationDelegateProxy.proxy(for: base)
    }
    
    /// 应用重新回到活动状态
    var didBecomeActive: Observable<AppState> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationDidBecomeActive(_:))).map { _ in return .active}
    }
    
    /// 应用从活动状态进入非活动状态
    var willResignActive: Observable<AppState> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationWillResignActive(_:))).map { _ in return .inactive }
    }
    
    /// 应用从后台恢复至前台（还不是活动状态）
    var willEnterForeground: Observable<AppState> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationWillEnterForeground(_:))).map { _ in return .inactive }
    }
    
    /// 应用进入到后台
    var didEnterBackground: Observable<AppState> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationDidEnterBackground(_:))).map { _ in return .background }
    }
    
    /// 应用终止
    var willTerminate: Observable<AppState> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationWillTerminate(_:))).map { _ in return .terminated }
    }
    
    /// 应用各状态变换序列
    var state:Observable<AppState> {
        return Observable.of(
            didBecomeActive,
            willResignActive,
            willEnterForeground,
            didEnterBackground,
            willTerminate
            )
            .merge()
            .startWith(base.applicationState.toAppState()) /// 为了让开始订阅时就能获取到当前状态
    }
    
}

class DelegateProxyUIApplicationController: BaseController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         我们知道 UIApplicationDelegate 协议中定义了关于程序启动各个过程的回调，比如：
         applicationWillResignActive 方法：在应用从活动状态进入非活动状态的时候会被调用（比如电话来了）。
         applicationWillTerminate方法：在应用终止的时候会被调用。
         过去我们通常都是在 AppDelegate.swift 里的相关回调方法中编写相应的业务逻辑。但一旦功能复杂些，这里就会变得十分混乱难以维护。而且有时想在其它模块中使用这些回调也不容易。
         本文演示如何通过对 UIApplication 进行 Rx 扩展，利用 RxSwift 的 DelegateProxy 实现 UIApplicationDelegate 相关回调方法的封装。从而让 UIApplicationDelegate 回调可以在任何模块中都可随时调用。
         */
        
        /// 应用重新回到活动状态
        let application = UIApplication.shared
        application.rx
            .didBecomeActive
            .subscribe(onNext: { _ in
                print("应用进入活动状态。")
            })
            .disposed(by: disposeBag)
        
        /// 应用从活动状态进入非活动状态
        application.rx
            .willResignActive
            .subscribe(onNext: { _ in
                print("应用从活动状态进入非活动状态。")
            })
            .disposed(by: disposeBag)
        
        /// 应用从后台恢复至前台（还不是活动状态）
        application.rx
            .willEnterForeground
            .subscribe(onNext: { _ in
                print("应用从后台恢复至前台（还不是活动状态）。")
            })
            .disposed(by: disposeBag)
        
        /// 应用进入到后台
        application.rx
            .didEnterBackground
            .subscribe(onNext: { _ in
                print("应用进入到后台。")
            })
            .disposed(by: disposeBag)
        
        /// 应用终止
        application.rx
            .willTerminate
            .subscribe(onNext: { _ in
                print("应用终止。")
            })
            .disposed(by: disposeBag)
    }
}
