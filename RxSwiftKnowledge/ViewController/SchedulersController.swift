//
//  SchedulersController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/2/28.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SchedulersController: BaseController {

    var data:Data?    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         二十、调度器（Schedulers）
         1，基本介绍
         （1）调度器（Schedulers）是 RxSwift 实现多线程的核心模块，它主要用于控制任务在哪个线程或队列运行。
         （2）RxSwift 内置了如下几种 Scheduler：
         CurrentThreadScheduler：表示当前线程 Scheduler。（默认使用这个）
         MainScheduler：表示主线程。如果我们需要执行一些和 UI 相关的任务，就需要切换到该 Scheduler运行。
         SerialDispatchQueueScheduler：封装了 GCD 的串行队列。如果我们需要执行一些串行任务，可以切换到这个 Scheduler 运行。
         ConcurrentDispatchQueueScheduler：封装了 GCD 的并行队列。如果我们需要执行一些并发任务，可以切换到这个 Scheduler 运行。
         OperationQueueScheduler：封装了 NSOperationQueue。
         
         2，使用样例
         这里以请求网络数据并显示为例。我们在后台发起网络请求，然后解析数据，最后在主线程刷新页面。
         
         3，subscribeOn 与 observeOn 区别
         （1）subscribeOn()
         该方法决定数据序列的构建函数在哪个 Scheduler 上运行。
         比如下面样例，由于获取数据、解析数据需要花费一段时间的时间，所以通过 subscribeOn 将其切换到后台 Scheduler 来执行。这样可以避免主线程被阻塞。
         
         （2）observeOn()
         该方法决定在哪个 Scheduler 上监听这个数据序列。
         比如下面样例，我们获取并解析完毕数据后又通过 observeOn 方法切换到主线程来监听并且处理结果。
         */
        /// 过去我们使用 GCD 来实现，代码大概是这样的：
        DispatchQueue.global(qos: .userInitiated).async {
            let data = try? Data(contentsOf: URL(string: "www.apple.com")!)
            
            /// 再到主线程显示结果
            self.data = data
        }
        
        /// 如果使用 RxSwift 来实现，代码大概是这样的：
        let rxData:Observable<Data> = Observable<Data>.of(Data())
        _ = rxData.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated)) /// 后台构建序列
            .observeOn(MainScheduler.instance) /// 主线程监听并处理序列结果
            .subscribe(onNext: {[weak self] data in
                if let self = self {
                    self.data = data
                }
            }).disposed(by: disposeBag)
    }
}

