//
//  SendMessageAndMethodInvokedController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/3/12.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit

class SendMessageAndMethodInvokedController: BaseController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         一、基本介绍
         1，sendMessage 与 methodInvoked 的区别
         （1）在之前的几篇文章中，我用到了 methodInvoked 这个 Rx 扩展方法，其作用是获取代理方法执行后产生的数据流。
          DelegateProxyLocationController.swift
          DelegateProxyUIImagePickerController.swift
         
         （2）除了 methodInvoked 外，还有个 sentMessage 方法也有同样的作用，它们间只有一个区别：
         sentMessage 会在调用方法前发送值。
         methodInvoked 会在调用方法后发送值。
         
         2，实现原理
         （1）其原理简单说就是利用 Runtime 消息转发机制来转发代理方法。同时在调用返回值为空的代理方法的前后分别产生两种数据流。
         （2）比如最开始的代理为 A，然后我们把代理改为 AProxy，并把 A 设置为 AProxy 的_forwardToDelegate。这样所有的代理方法将会变成到达 AProxy，接着 AProxy对这些方法进行如下操作：
         首先调用 sentMessage 方法
         接着调用原代理方法
         最后调用 methodInvoked 方法
         */
        
        /** 我们分别通过 sendMessage 以及 methodInvoked 方法来获取 selector 对应的 Observable，并将它们与原方法做比较，看看执行的先后顺序。
           （注意：两个样例中 selector 都不是代理方法，但不影响效果的演示。）
          */
        
        /// 拦截 VC 的 viewWillAppear 方法
        /// 使用sentMessage方法获取Observable
        self.rx.sentMessage(#selector(ViewController.viewWillAppear(_:))).subscribe(onNext: { _ in
            print("viewWillAppear_sentMessage")
        }).disposed(by: disposeBag)
        
        /// 使用methodInvoked方法获取Observable
        self.rx.methodInvoked(#selector(ViewController.viewWillAppear(_:))).subscribe(onNext: { _ in
            print("viewWillAppear_methodInvoked")
        }).disposed(by: disposeBag)
        
        /// 拦截自定义方法
        /// 使用sentMessage获取方法执行前的序列
        self.rx.sentMessage(#selector(SendMessageAndMethodInvokedController.test)).subscribe(onNext: { value in
                print("\(value[0])_sentMessage")
            }).disposed(by: disposeBag)
        
        /// 使用methodInvoked获取方法执行后的序列
        self.rx.methodInvoked(#selector(SendMessageAndMethodInvokedController.test)).map { a in
            return try castOrThrow(String.self, a[0])
            }.subscribe(onNext: { value in
                print("\(value)_methodInvoked")
            }).disposed(by: disposeBag)
        
        /// 调用自定义方法
        test("www.apple.com")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
    }
}

extension SendMessageAndMethodInvokedController {
    @objc fileprivate func test(_ value:String) {
        print("\(value)")
    }
}
