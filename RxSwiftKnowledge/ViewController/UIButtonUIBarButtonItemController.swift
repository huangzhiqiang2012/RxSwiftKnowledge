//
//  UIButtonUIBarButtonItemController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/2/28.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class UIButtonUIBarButtonItemController: BaseController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: (view.bounds.size.width - 100) * 0.5, y: 100, width: 100, height: 30)
        button.backgroundColor = UIColor.brown
        button.setTitle("按钮", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .disabled)
        view.addSubview(button)
 
        /**
         1，按钮点击响应
         假设我们想实现点击按钮后，弹出一个消息提示框。
         */
//        button.rx.tap.subscribe(onNext: {[weak self] in
//            self?.showMessage("按钮被点击")
//        }).disposed(by: disposeBag)
        
        /**
         或者这么写也行：
         */
        button.rx.tap.bind { [weak self] in
            self?.showMessage("按钮被点击")
        }.disposed(by: disposeBag)
        
        /**
         2，按钮标题（title）的绑定
         （1）下面样例当程序启动时就开始计数，同时将拼接后的最新文本作为 button 的标题。
         （2）代码如下，其中 rx.title 为 setTitle(_:for:) 的封装。
         */
//        let timer1 = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
//        timer1.map {"计数\($0)"}.bind(to: button.rx.title(for: .normal)).disposed(by: disposeBag)
        
        /**
         3，按钮富文本标题（attributedTitle）的绑定
         （1）下面样例当程序启动时就开始计时，同时将已过去的时间格式化，并设置好文字样式后显示在 button 标签上。
         （2）代码如下，其中 rx.attributedTitle 为 setAttributedTitle(_:controlState:) 的封装。
         */
//        let timer2 = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
//        timer2.map(formatTimeInterval).bind(to: button.rx.attributedTitle()).disposed(by: disposeBag)
        
        /**
         4，按钮图标（image）的绑定
         （1）下面样例当程序启动时就开始计数，根据奇偶数选择相应的图片作为 button 的图标。
         （2）代码如下，其中 rx.image 为 setImage(_:for:) 的封装。
         */
//        let timer3 = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
//        timer3.map ({
//            let name = $0 % 2 == 0 ? "arrow_left" : "arrow_right"
//            return UIImage(named: name)!
//        }).bind(to: button.rx.image()).disposed(by: disposeBag)
        
        /**
         5，按钮是否可用（isEnabled）的绑定
         下面样例当我们切换开关（UISwitch）时，button 会在可用和不可用的状态间切换。
         */
        let switch1 = UISwitch(frame: CGRect(x: button.frame.origin.x, y: button.frame.maxY + 50, width: button.bounds.size.width, height: button.bounds.size.height))
        view.addSubview(switch1)
        switch1.rx.isOn.bind(to: button.rx.isEnabled).disposed(by: disposeBag)
        
        /**
         6，按钮是否选中（isSelected）的绑定
         下面样例中三个按钮只有一个按钮处于选中状态。即点击选中任意一个按钮，另外两个按钮则变为未选中状态。
         */
        let button1 = UIButton(type: .custom)
        button1.frame = CGRect(x: 50, y: switch1.frame.maxY + 50, width: 60, height: 30)
        button1.backgroundColor = UIColor.brown
        button1.setTitle("按钮1", for: .normal)
        button1.setTitleColor(UIColor.blue, for: .normal)
        button1.setTitleColor(UIColor.red, for: .selected)
        view.addSubview(button1)
        
        let button2 = UIButton(type: .custom)
        button2.frame = CGRect(x: button1.frame.maxX + 30, y: button1.frame.origin.y, width: button1.bounds.size.width, height: button1.bounds.size.height)
        button2.backgroundColor = UIColor.brown
        button2.setTitle("按钮2", for: .normal)
        button2.setTitleColor(UIColor.blue, for: .normal)
        button2.setTitleColor(UIColor.red, for: .selected)
        view.addSubview(button2)
        
        let button3 = UIButton(type: .custom)
        button3.frame = CGRect(x: button2.frame.maxX + 30, y: button1.frame.origin.y, width: button1.bounds.size.width, height: button1.bounds.size.height)
        button3.backgroundColor = UIColor.brown
        button3.setTitle("按钮3", for: .normal)
        button3.setTitleColor(UIColor.blue, for: .normal)
        button3.setTitleColor(UIColor.red, for: .selected)
        view.addSubview(button3)
        
        /// 默认选中第一个按钮
        button1.isSelected = true
        
        /// 强制解包，避免后面还需要处理可选类型
        let buttons = [button1, button2, button3].map {$0!}
        
        /// 创建一个可观察序列，它可以发送最后一次点击的按钮（也就是我们需要选中的按钮）
        let selectedButton = Observable.from(buttons.map({ button in
            button.rx.tap.map({button})
        })).merge()
        
        /// 对于每一个按钮都对selectedButton进行订阅，根据它是否是当前选中的按钮绑定isSelected属性
        for button in buttons {
            selectedButton.map {$0 == button}.bind(to: button.rx.isSelected).disposed(by: disposeBag)
        }
    }
}

extension UIButtonUIBarButtonItemController {
    fileprivate func showMessage(_ text:String) -> Void {
        let alertController = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        let sureAction = UIAlertAction(title: "确定", style: .default, handler: nil)
        alertController.addAction(sureAction)
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func formatTimeInterval(ms: NSInteger) -> NSMutableAttributedString {
        let string = String(format: "%0.2d:%0.2d.%0.1d",
                            arguments: [(ms / 600) % 600, (ms % 600 ) / 10, ms % 10])
        let attributeString = NSMutableAttributedString(string: string)
        attributeString.addAttribute(NSAttributedString.Key.font,
                                     value: UIFont(name: "HelveticaNeue-Bold", size: 18)!,
                                     range: NSMakeRange(0, 5))
        attributeString.addAttribute(NSAttributedString.Key.foregroundColor,
                                     value: UIColor.white, range: NSMakeRange(0, 5))
        attributeString.addAttribute(NSAttributedString.Key.backgroundColor,
                                     value: UIColor.orange, range: NSMakeRange(0, 5))
        return attributeString
    }
}
