//
//  ErrorHandlingOperatorsController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/2/28.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ErrorHandlingOperatorsController: BaseController {    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enum MyError : Error {
            case A
            case B
        }
        
        /**
         错误处理操作（Error Handling Operators）
         错误处理操作符可以用来帮助我们对 Observable 发出的 error 事件做出响应，或者从错误中恢复。
         */
        
        /**
         1，catchErrorJustReturn
         当遇到 error 事件的时候，就返回指定的值，然后结束。
         */
        let sequenceThatFails1 = PublishSubject<String>()
        _ = sequenceThatFails1.catchErrorJustReturn("错误").subscribe(onNext: {print($0)}).disposed(by: disposeBag)
        
        sequenceThatFails1.onNext("a")
        sequenceThatFails1.onNext("b")
        sequenceThatFails1.onNext("c")
        sequenceThatFails1.onError(MyError.A)
        sequenceThatFails1.onNext("d")
        
        /**
         2，catchError
         该方法可以捕获 error，并对其进行处理。
         同时还能返回另一个 Observable 序列进行订阅（切换到新的序列）。
         */
        let sequenceThatFails2 = PublishSubject<String>()
        let recoverySequence = Observable.of("1", "2", "3")
        _ = sequenceThatFails2.catchError {
            print("Error:", $0)
            return recoverySequence
            }.subscribe(onNext: {print($0)}).disposed(by: disposeBag)
        
        sequenceThatFails2.onNext("a")
        sequenceThatFails2.onNext("b")
        sequenceThatFails2.onNext("c")
        sequenceThatFails2.onError(MyError.A)
        sequenceThatFails2.onNext("d")
        
        /**
         3，retry
         使用该方法当遇到错误的时候，会重新订阅该序列。比如遇到网络请求失败时，可以进行重新连接。
         retry() 方法可以传入数字表示重试次数。不传的话只会重试一次。
         */
        var count = 1
        let sequenceThatErrors = Observable<String>.create { observer in
            observer.onNext("a")
            observer.onNext("b")
            
            /// 让第一个订阅时发生错误
            if count == 1 {
                observer.onError(MyError.A)
                print("Error encountered")
                count += 1
            }
            
            observer.onNext("c")
            observer.onNext("d")
            
            return Disposables.create()
        }
        
        sequenceThatErrors.retry(2).subscribe(onNext: {print($0)}).disposed(by: disposeBag)
    }
}
