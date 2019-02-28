//
//  ConditionalAndBooleanOperatorsController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/2/28.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ConditionalAndBooleanOperatorsController: BaseController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         条件和布尔操作符（Conditional and Boolean Operators）
         条件和布尔操作会根据条件发射或变换 Observables，或者对他们做布尔运算。
         */
        
        /**
         1，amb
         当传入多个 Observables 到 amb 操作符时，它将取第一个发出元素或产生事件的 Observable，然后只发出它的元素。并忽略掉其他的 Observables。
         */
        let subject1 = PublishSubject<Int>()
        let subject2 = PublishSubject<Int>()
        let subject3 = PublishSubject<Int>()
        
        /// 只发出subject2的元素
        _ = subject1.amb(subject2).amb(subject3).subscribe(onNext: {print($0)}).disposed(by: disposeBag)
        
        subject2.onNext(1)
        subject1.onNext(20)
        subject2.onNext(2)
        subject1.onNext(40)
        subject3.onNext(0)
        subject2.onNext(3)
        subject1.onNext(60)
        subject3.onNext(0)
        subject3.onNext(0)
        
        /**
         2，takeWhile
         该方法依次判断 Observable 序列的每一个值是否满足给定的条件。 当第一个不满足条件的值出现时，它便自动完成。
         */
        _ = Observable.of(1, 2, 3, 4, 5, 6).takeWhile({$0 < 4}).subscribe(onNext: {print($0)}).disposed(by: disposeBag)
        
        /**
         3，takeUntil
         除了订阅源 Observable 外，通过 takeUntil 方法我们还可以监视另外一个 Observable， 即 notifier。
         如果 notifier 发出值或 complete 通知，那么源 Observable 便自动完成，停止发送事件。
         */
        let source1 = PublishSubject<String>()
        let notifier1 = PublishSubject<String>()
        _ = source1.takeUntil(notifier1).subscribe(onNext: {print($0)}).disposed(by: disposeBag)
        
        source1.onNext("a")
        source1.onNext("b")
        source1.onNext("c")
        source1.onNext("d")
        
        /// 停止接收消息
        notifier1.onNext("z")
        
        source1.onNext("e")
        source1.onNext("f")
        source1.onNext("g")
        
        /**
         4，skipWhile
         该方法用于跳过前面所有满足条件的事件。
         一旦遇到不满足条件的事件，之后就不会再跳过了。
         */
        _ = Observable.of(1, 2, 3, 4, 5, 6).skipWhile({$0 < 4}).subscribe(onNext: {print($0)}).disposed(by: disposeBag)
        
        /**
         5，skipUntil
         同上面的 takeUntil 一样，skipUntil 除了订阅源 Observable 外，通过 skipUntil方法我们还可以监视另外一个 Observable， 即 notifier 。
         与 takeUntil 相反的是。源 Observable 序列事件默认会一直跳过，直到 notifier 发出值或 complete 通知。
         */
        let source2 = PublishSubject<Int>()
        let notifier2 = PublishSubject<Int>()
        _ = source2.skipUntil(notifier2).subscribe(onNext: {print($0)}).disposed(by: disposeBag)
        
        source2.onNext(1)
        source2.onNext(2)
        source2.onNext(3)
        source2.onNext(4)
        source2.onNext(5)
        
        /// 开始接收消息
        notifier2.onNext(0)
        
        source2.onNext(6)
        source2.onNext(7)
        source2.onNext(8)
        
        /// 仍然接收消息
        notifier2.onNext(0)
        
        source2.onNext(9)
    }
}


