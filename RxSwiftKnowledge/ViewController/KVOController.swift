//
//  KVOController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/3/12.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class KVOController: BaseController {
    
    @objc dynamic var message = "www.apple.com"
    
    var tableView:UITableView!
    
    /// 导航栏背景视图
    var barImageView:UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         1，KVO 介绍
         KVO（键值观察）是一种 Objective-C 的回调机制，全称为：key-value-observing。
         该机制简单来说就是在某个对象注册监听者后，当被监听的对象发生改变时，对象会发送一个通知给监听者，以便监听者执行回调操作。
         
         2，RxSwift 中的 KVO
         RxCocoa 提供了 2 个可观察序列 rx.observe 和 rx.observeWeakly，它们都是对 KVO 机制的封装，二者的区别如下。
         （1）性能比较
         rx.observe 更加高效，因为它是一个 KVO 机制的简单封装。
         rx.observeWeakly 执行效率要低一些，因为它要处理对象的释放防止弱引用（对象的 dealloc 关系）。
         
         （2）使用场景比较
         在可以使用 rx.observe 的地方都可以使用 rx.observeWeakly。
         使用 rx.observe 时路径只能包括 strong 属性，否则就会有系统崩溃的风险。而 rx.observeWeakly 可以用在 weak 属性上。
         */
        
        /**
         1，监听基本类型的属性
         （1）我们创建一个定时器，每隔 1 秒钟给变量 message 尾部添加一个感叹号（!）。同时对这个属性进行监听，当值改变时将最新值输出到控制台中。
         注意：
         监听的属性需要有 dynamic 修饰符。
         本样例需要使用 rx.observeWeakly，不能用 rx.observe，否则会造成循环引用，引起内存泄露。
         */
//        Observable<Int>.interval(1, scheduler: MainScheduler.instance).subscribe(onNext: { [unowned self] _ in
//            self.message.append("!")
//        }).disposed(by: disposeBag)
        
        /// 监听message变量的变化
//        _ = self.rx.observeWeakly(String.self, "message").subscribe(onNext: { (value) in
//            print(value ?? "")
//        })
        
        /**
         2，监听视图尺寸变化
         （1）我们对 view.frame 进行监听，当其改变时将最新值输出到控制台中。
         （2）程序启动后默认是竖屏状态，接着我们将其变成横屏显示。
         注意：这里必须使用 rx.observe，如果使用 rx.observeWeakly 则监听不到。
         */
        /// 监听视图frame的变化
        _ = self.rx.observe(CGRect.self, "view.frame").subscribe(onNext: { (frame) in
            print("--- 视图尺寸发生变化 ---")
            print(frame!)
            print("\n")
        })
        
        /**
         3，渐变导航栏效果
         */
        self.navigationController?.navigationBar.barTintColor = .orange
        
        /// 获取导航栏背景视图
        self.barImageView = self.navigationController?.navigationBar.subviews.first
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: UIScreen.main.bounds.size.height - (navigationController?.navigationBar.bounds.size.height)! - UIApplication.shared.statusBarFrame.size.height), style: .plain)
        let identifier = "cell"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        view.addSubview(tableView)
        
        let items = Observable.just(Array(0...100).map { "这个是条目\($0)"})
        
        items.bind(to: tableView.rx.items) { tableView, row, element in
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
            cell.textLabel?.text = element
            return cell
        }.disposed(by: disposeBag)
        
        /// 使用kvo来监听视图偏移量变化
        _ = tableView.rx.observe(CGPoint.self, "contentOffset").subscribe(onNext: {[weak self] (offset) in
            var delta = offset!.y / CGFloat(64) + 1
            delta = CGFloat.maximum(delta, 0)
            self?.barImageView?.alpha = CGFloat.minimum(delta, 1)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barTintColor = .white
    }
}
