//
//  TransformingObservablesController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/2/28.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class TransformingObservablesController: BaseController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         变换操作（Transforming Observables）
         变换操作指的是对原始的 Observable 序列进行一些转换，类似于 Swift 中 CollectionType 的各种转换。
         */
        /**
         1，buffer
         buffer 方法作用是缓冲组合，第一个参数是缓冲时间，第二个参数是缓冲个数，第三个参数是线程。
         该方法简单来说就是缓存 Observable 中发出的新元素，当元素达到某个数量，或者经过了特定的时间，它就会将这个元素集合发送出来。
         */
        //        let subject1 = PublishSubject<String>()
        
        /// 每缓存3个元素则组合起来一起发出。
        /// 如果1秒钟内不够3个也会发出（有几个发几个，一个都没有发空数组 []）
        //        _ = subject1.buffer(timeSpan: 1, count: 3, scheduler: MainScheduler.instance).subscribe(onNext: {
        //            print($0)
        //        }).disposed(by: disposeBag)
        //
        //        subject1.onNext("a")
        //        subject1.onNext("b")
        //        subject1.onNext("c")
        //
        //        subject1.onNext("1")
        //        subject1.onNext("2")
        //        subject1.onNext("3")
        
        /**
         2，window
         window 操作符和 buffer 十分相似。不过 buffer 是周期性的将缓存的元素集合发送出来，而 window 周期性的将元素集合以 Observable 的形态发送出来。
         同时 buffer要等到元素搜集完毕后，才会发出元素序列。而 window 可以实时发出元素序列。
         */
        //        let subject2 = PublishSubject<String>()
        
        /// 每3个元素作为一个子Observable发出。
        //        _ = subject2.window(timeSpan: 1, count: 3, scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] in
        //            print("subscribe: \($0)")
        //            $0.asObservable().subscribe(onNext: {
        //                print($0)
        //            }).disposed(by: self!.disposeBag)
        //        }).disposed(by: disposeBag)
        //
        //        subject2.onNext("a")
        //        subject2.onNext("b")
        //        subject2.onNext("c")
        //
        //        subject2.onNext("1")
        //        subject2.onNext("2")
        //        subject2.onNext("3")
        
        /**
         3，map
         该操作符通过传入一个函数闭包把原来的 Observable 序列转变为一个新的 Observable 序列。
         */
        _ = Observable.of(1, 2, 3).map {$0 * 10}.subscribe(onNext: {print($0)}).disposed(by: disposeBag)
        
        /**
         4，flatMap
         map 在做转换的时候容易出现“升维”的情况。即转变之后，从一个序列变成了一个序列的序列。
         而 flatMap 操作符会对源 Observable 的每一个元素应用一个转换方法，将他们转换成 Observables。 然后将这些 Observables 的元素合并之后再发送出来。即又将其 "拍扁"（降维）成一个 Observable 序列。
         这个操作符是非常有用的。比如当 Observable 的元素本生拥有其他的 Observable 时，我们可以将所有子 Observables 的元素发送出来。
         */
        //        let subject3 = BehaviorSubject(value: "A")
        //        let subject4 = BehaviorSubject(value: "1")
        //        let variable1 = Variable(subject3)
        //
        //        _ = variable1.asObservable().flatMap {$0}.subscribe(onNext: {print($0)}).disposed(by: disposeBag)
        //        subject3.onNext("B")
        //        variable1.value = subject4
        //        subject4.onNext("2")
        //        subject3.onNext("C")
        
        /**
         5，flatMapLatest
         flatMapLatest与flatMap 的唯一区别是：flatMapLatest只会接收最新的value 事件。
         */
        //        let subject5 = BehaviorSubject(value: "A")
        //        let subject6 = BehaviorSubject(value: "1")
        //        let variable2 = Variable(subject5)
        //
        //        _ = variable2.asObservable().flatMapLatest {$0}.subscribe(onNext: {print($0)}).disposed(by: disposeBag)
        //        subject5.onNext("B")
        //        variable2.value = subject6
        //        subject6.onNext("2")
        //        subject5.onNext("C")
        
        /**
         6，concatMap
         concatMap 与 flatMap 的唯一区别是：当前一个 Observable 元素发送完毕后，后一个Observable 才可以开始发出元素。或者说等待前一个 Observable 产生完成事件后，才对后一个 Observable 进行订阅。
         */
        //        let subject7 = BehaviorSubject(value: "A")
        //        let subject8 = BehaviorSubject(value: "1")
        //        let variable3 = Variable(subject7)
        //
        //        _ = variable3.asObservable().concatMap {$0}.subscribe(onNext: {print($0)}).disposed(by: disposeBag)
        //        subject7.onNext("B")
        //        variable3.value = subject8
        //        subject8.onNext("2")
        //        subject7.onNext("C")
        
        /// 只有前一个序列结束后，才能接收下一个序列
        //        subject7.onCompleted()
        
        /**
         7，scan
         scan 就是先给一个初始化的数，然后不断的拿前一个结果和最新的值进行处理操作。
         */
        _ = Observable.of(1, 2, 3, 4, 5).scan(0) { acum, elem in
            acum + elem
            }.subscribe(onNext: {print($0)}).disposed(by: disposeBag)
        
        /**
         8，groupBy
         groupBy 操作符将源 Observable 分解为多个子 Observable，然后将这些子 Observable 发送出来。
         也就是说该操作符会将元素通过某个键进行分组，然后将分组后的元素序列以 Observable 的形态发送出来。
         */
        /// 将奇数偶数分成两组
        Observable<Int>.of(0, 1, 2, 3, 4, 5).groupBy(keySelector: { (element) -> String in
            return element % 2 == 0 ? "偶数" : "奇数"
        }).subscribe {[weak self] (event) in
            switch event {
            case .next(let group):
                group.asObservable().subscribe({ (event) in
                    print("key: \(group.key) event: \(event)")
                }).disposed(by: self!.disposeBag)
            default:print("")
            }
            }.disposed(by: disposeBag)
    }
}
