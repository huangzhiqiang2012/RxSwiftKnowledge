//
//  CombiningObservablesController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/2/28.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class CombiningObservablesController: BaseController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         结合操作（Combining Observables）
         结合操作（或者称合并操作）指的是将多个 Observable 序列进行组合，拼装成一个新的 Observable 序列。
         */
        
        /**
         1，startWith
         该方法会在 Observable 序列开始之前插入一些事件元素。即发出事件消息之前，会先发出这些预先插入的事件消息。
         插入多个数据也是可以的
         */
        _ = Observable.of("2", "3").startWith("1").subscribe(onNext: {print($0)}).disposed(by: disposeBag)
        
        _ = Observable.of("2", "3").startWith("a").startWith("b").startWith("c").subscribe(onNext: {print($0)}).disposed(by: disposeBag)
        
        /**
         2，merge
         该方法可以将多个（两个或两个以上的）Observable 序列合并成一个 Observable序列。
         */
        let subject1 = PublishSubject<Int>()
        let subject2 = PublishSubject<Int>()
        
        _ = Observable.of(subject1, subject2).merge().subscribe(onNext: {print($0)}).disposed(by: disposeBag)
        subject1.onNext(20)
        subject1.onNext(40)
        subject1.onNext(60)
        subject2.onNext(1)
        subject1.onNext(80)
        subject1.onNext(100)
        subject2.onNext(1)
        
        /**
         3，zip
         该方法可以将多个（两个或两个以上的）Observable 序列压缩成一个 Observable 序列。
         而且它会等到每个 Observable 事件一一对应地凑齐之后再合并。
         */
        let subject3 = PublishSubject<Int>()
        let subject4 = PublishSubject<String>()
        
        _ = Observable.zip(subject3, subject4) {
            "\($0)\($1)"
            }.subscribe(onNext: {print($0)}).disposed(by: disposeBag)
        subject3.onNext(1)
        subject4.onNext("A")
        subject3.onNext(2)
        subject4.onNext("B")
        subject4.onNext("C")
        subject4.onNext("D")
        subject3.onNext(3)
        subject3.onNext(4)
        subject3.onNext(5)
        
        /**
         4，combineLatest
         该方法同样是将多个（两个或两个以上的）Observable 序列元素进行合并。
         但与 zip 不同的是，每当任意一个 Observable 有新的事件发出时，它会将每个 Observable 序列的最新的一个事件元素进行合并。
         */
        let subject5 = PublishSubject<Int>()
        let subject6 = PublishSubject<String>()
        
        _ = Observable.combineLatest(subject5, subject6) {
            "\($0)\($1)"
            }.subscribe(onNext: {print($0)}).disposed(by: disposeBag)
        subject5.onNext(1)
        subject6.onNext("A")
        subject5.onNext(2)
        subject6.onNext("B")
        subject6.onNext("C")
        subject6.onNext("D")
        subject5.onNext(3)
        subject5.onNext(4)
        subject5.onNext(5)
        
        /**
         5，withLatestFrom
         该方法将两个 Observable 序列合并为一个。每当 self 队列发射一个元素时，便从第二个序列中取出最新的一个值。
         */
        let subject7 = PublishSubject<String>()
        let subject8 = PublishSubject<String>()
        
        _ = subject7.withLatestFrom(subject8).subscribe(onNext: {print($0)}).disposed(by: disposeBag)
        subject7.onNext("A")
        subject8.onNext("1")
        subject7.onNext("B")
        subject7.onNext("C")
        subject8.onNext("2")
        subject7.onNext("D")
        
        /**
         6，switchLatest
         switchLatest 有点像其他语言的switch 方法，可以对事件流进行转换。
         比如本来监听的 subject1，我可以通过更改 variable 里面的 value 更换事件源。变成监听 subject2。
         */
        let subject9 = BehaviorSubject(value: "A")
        let subject10 = BehaviorSubject(value: "1")
        let variable = Variable(subject9)
        
        _ = variable.asObservable().switchLatest().subscribe(onNext: {print($0)}).disposed(by: disposeBag)
        subject9.onNext("B")
        subject9.onNext("C")
        
        /// 改变事件源
        variable.value = subject10
        subject9.onNext("D")
        subject10.onNext("2")
        
        /// 改变事件源
        variable.value = subject9
        subject10.onNext("3")
        subject9.onNext("E")
    }
}
