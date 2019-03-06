//
//  UILabelController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/2/28.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class UILabelController: BaseController {
    
    var timer:Observable<Int>?

    override func viewDidLoad() {
        super.viewDidLoad()
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        label.center = view.center
        view.addSubview(label)
        
        /**
         RxSwift是一个用于与 Swift 语言交互的框架，但它只是基础，并不能用来进行用户交互、网络请求等。
         而 RxCocoa 是让 Cocoa APIs 更容易使用响应式编程的一个框架。
         RxCocoa 能够让我们方便地进行响应式网络请求、响应式的用户交互、绑定数据模型到 UI 控件等等。而且大多数的 UIKit 控件都有响应式扩展，它们都是通过 rx 属性进行使用。
         */
        /**
         一、UILabel
         1，将数据绑定到 text 属性上（普通文本）
         */
        
        /// 创建一个计时器（每0.1秒发送一个索引数）
        //        let timer1 = Observable<Int>.interval(0.1, scheduler: MainScheduler.instance)
        
        /// 将已过去的时间格式化成想要的字符串，并绑定到label上
        //        timer1.map {String(format: "%0.2d:%0.2d.%0.1d", arguments:[($0 / 600) % 600, ($0 % 600) / 10, $0 % 10])}.bind(to: label.rx.text).disposed(by: disposeBag)
        
        /**
         2，将数据绑定到 attributedText 属性上（富文本）
         */
        /// 创建一个计时器（每0.1秒发送一个索引数）
        let timer2 = Observable<Int>.interval(0.1, scheduler: MainScheduler.instance)
        
        /// 将已过去的时间格式化成想要的字符串，并绑定到label上
        timer2.map(formatTimeInterval)
            .bind(to: label.rx.attributedText)
            .disposed(by: disposeBag)
    }
}

extension UILabelController {
    fileprivate func formatTimeInterval(ms: NSInteger) -> NSMutableAttributedString {
        let string = String(format: "%0.2d:%0.2d.%0.1d", arguments:[(ms / 600) % 600, (ms % 600) / 10, ms % 10])
        let attributeString = NSMutableAttributedString(string: string)
        attributeString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "HelveticaNeue-Bold", size: 16) as Any, range: NSMakeRange(0, 5))
        attributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSMakeRange(0, 5))
        attributeString.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.orange, range: NSMakeRange(0, 5))
        return attributeString
    }
}
