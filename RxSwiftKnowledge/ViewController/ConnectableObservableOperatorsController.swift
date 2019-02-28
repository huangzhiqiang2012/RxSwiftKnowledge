//
//  ConnectableObservableOperatorsController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/2/28.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ConnectableObservableOperatorsController: BaseController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         连接操作（Connectable Observable Operators）
         */
        /**
         1，可连接的序列
         可连接的序列（Connectable Observable）：
         （1）可连接的序列和一般序列不同在于：有订阅时不会立刻开始发送事件消息，只有当调用 connect()之后才会开始发送值。
         （2）可连接的序列可以让所有的订阅者订阅后，才开始发出事件消息，从而保证我们想要的所有订阅者都能接收到事件消息。
         */
        
        /// 每隔1秒钟发送1个事件
        //        let interval1 = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        
        /// 第一个订阅者（立刻开始订阅）
        //        _ = interval1.subscribe(onNext: {print("订阅1: \($0)")})
        
        /// 第二个订阅者（延迟5秒开始订阅）
        //        delay(5) {
        //            _ = interval1.subscribe(onNext: {print("订阅2: \($0)")})
        //        }
        
        /**
         2，publish
         publish 方法会将一个正常的序列转换成一个可连接的序列。同时该序列不会立刻发送事件，只有在调用 connect 之后才会开始。
         */
        /// 每隔1秒钟发送1个事件
        //        let interval2 = Observable<Int>.interval(1, scheduler: MainScheduler.instance).publish()
        
        /// 第一个订阅者（立刻开始订阅）
        //        _ = interval2.subscribe(onNext: {print("订阅1: \($0)")})
        
        /// 相当于把事件消息推迟了两秒
        //        delay(2) {
        //            _ = interval2.connect()
        //        }
        
        /// 第二个订阅者（延迟5秒开始订阅）
        //        delay(5) {
        //            _ = interval2.subscribe(onNext: { print("订阅2: \($0)") })
        //        }
        
        /**
         3，replay
         replay 同上面的 publish 方法相同之处在于：会将一个正常的序列转换成一个可连接的序列。同时该序列不会立刻发送事件，只有在调用 connect 之后才会开始。
         replay 与 publish 不同在于：新的订阅者还能接收到订阅之前的事件消息（数量由设置的 bufferSize 决定）。
         */
        //        let interval3 = Observable<Int>.interval(1, scheduler: MainScheduler.instance).replay(5)
        
        /// 第一个订阅者（立刻开始订阅）
        //        _ = interval3.subscribe(onNext: {print("订阅1: \($0)")})
        
        /// 相当于把事件消息推迟了两秒
        //        delay(2) {
        //            _ = interval3.connect()
        //        }
        
        /// 第二个订阅者（延迟5秒开始订阅）
        //        delay(5) {
        //            _ = interval3.subscribe(onNext: {print("订阅2: \($0)")})
        //        }
        
        /**
         4，multicast
         multicast 方法同样是将一个正常的序列转换成一个可连接的序列。
         同时 multicast 方法还可以传入一个 Subject，每当序列发送事件时都会触发这个 Subject 的发送。
         */
        /// 创建一个Subject（后面的multicast()方法中传入）
        //        let subject = PublishSubject<Int>()
        
        /// 这个Subject的订阅
        //        _ = subject.subscribe(onNext: {print("Subject: \($0)")})
        
        /// 每隔1秒钟发送1个事件
        //        let interval4 = Observable<Int>.interval(1, scheduler: MainScheduler.instance).multicast(subject)
        
        /// 第一个订阅者（立刻开始订阅）
        //        _ = interval4.subscribe(onNext: {print("订阅1: \($0)")})
        
        /// 相当于把事件消息推迟了两秒
        //        delay(2) {
        //            _ = interval4.connect()
        //        }
        
        /// 第二个订阅者（延迟5秒开始订阅）
        //        delay(5) {
        //            _ = interval4.subscribe(onNext: {print("订阅2: \($0)")})
        //        }
        
        /**
         5，refCount
         refCount 操作符可以将可被连接的 Observable 转换为普通 Observable
         即该操作符可以自动连接和断开可连接的 Observable。当第一个观察者对可连接的Observable 订阅时，那么底层的 Observable 将被自动连接。当最后一个观察者离开时，那么底层的 Observable 将被自动断开连接。
         */
        /// 每隔1秒钟发送1个事件
        //        let interval5 = Observable<Int>.interval(1, scheduler: MainScheduler.instance).publish().refCount()
        
        /// 第一个订阅者（立刻开始订阅）
        //        _ = interval5.subscribe(onNext: {print("订阅1: \($0)")})
        
        /// 第二个订阅者（延迟5秒开始订阅）
        //        delay(5) {
        //            _ = interval5.subscribe(onNext: {print("订阅2: \($0)")})
        //        }
        
        /**
         6，share(relay:)
         该操作符将使得观察者共享源 Observable，并且缓存最新的 n 个元素，将这些元素直接发送给新的观察者。
         简单来说 shareReplay 就是 replay 和 refCount 的组合。
         */
        /// 每隔1秒钟发送1个事件
        let interval6 = Observable<Int>.interval(1, scheduler: MainScheduler.instance).share(replay: 5)
        
        /// 第一个订阅者（立刻开始订阅）
        _ = interval6.subscribe(onNext: { print("订阅1: \($0)") })
        
        /// 第二个订阅者（延迟5秒开始订阅）
        delay(5) {
            _ = interval6.subscribe(onNext: { print("订阅2: \($0)") })
        }
    }
}

extension ConnectableObservableOperatorsController {
    func delay(_ delay:Double, closure:@escaping() -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            closure()
        }
    }
}

