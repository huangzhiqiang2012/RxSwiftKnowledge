//
//  NotificationCenterController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/3/12.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class NotificationCenterObserver: NSObject {
    var name:String = ""
    
    init(name:String) {
        super.init()
        self.name = name
        
        /// 接收通知：
        let notificationName = Notification.Name(rawValue: "DownloadImageNotification")
        _ = NotificationCenter.default.rx.notification(notificationName).takeUntil(self.rx.deallocated) /// 页面销毁自动移除通知监听
            .subscribe(onNext: { notification in
                
                /// 获取通知数据
                let userInfo = notification.userInfo as! [String : AnyObject]
                let value1 = userInfo["value1"] as! String
                let value2 = userInfo["value2"] as! Int
                print("\(name) 获取到通知, 用户数据是 [\(value1), \(value2)]")
                
                sleep(1)
                print("\(name) 执行完毕")
            })
    }
}

class NotificationCenterController: BaseController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 监听应用进入后台通知
        NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification).takeUntil(self.rx.deallocated) /// 页面销毁自动移除通知监听
            .subscribe(onNext: { _ in
                print("程序进入到后台了")
            }).disposed(by: disposeBag)
        
        let textField = UITextField(frame: CGRect(x: 20, y: 100, width: view.bounds.size.width - 40, height: 30))
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .done
        view.addSubview(textField)
        
        /// 点击键盘上的完成按钮后，收起键盘
        textField.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: { _ in
            textField.resignFirstResponder()
        }).disposed(by: disposeBag)
        
        /// 监听键盘弹出通知
        NotificationCenter.default.rx.notification(UIApplication.keyboardWillShowNotification).takeUntil(self.rx.deallocated) /// 页面销毁自动移除通知监听
            .subscribe(onNext: { _ in
                print("键盘出现了")
            }).disposed(by: disposeBag)
        
        /// 监听键盘隐藏通知
        NotificationCenter.default.rx.notification(UIApplication.keyboardWillHideNotification).takeUntil(self.rx.deallocated) /// 页面销毁自动移除通知监听
            .subscribe(onNext: { _ in
                print("键盘消失了")
            }).disposed(by: disposeBag)
        
        /// 自定义通知的发送与接收
        let observers = [NotificationCenterObserver(name: "观察器1"), NotificationCenterObserver(name: "观察器2")]
        
        print("发送通知")
        let notificationName = Notification.Name(rawValue: "DownloadImageNotification")
        NotificationCenter.default.post(name: notificationName, object: observers, userInfo: ["value1" : "www.apple.com", "value2" : 123456])
        
        print("发送完毕")
    }
}
