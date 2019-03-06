//
//  WeakSelfUnownedSelfController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/3/5.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class WeakSelfUnownedSelfController: BaseController {
    
    fileprivate lazy var textField:UITextField = {
        let textField:UITextField = UITextField(frame: CGRect(x: 10, y: 100, width: view.bounds.size.width - 20, height: 30))
        textField.backgroundColor = UIColor.brown
        return textField
    }()
    
    fileprivate lazy var label:UILabel = {
        let label:UILabel = UILabel()
        label.text = "我是label"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         Swift使用自动引用计数（ARC）来管理应用程序的内存使用，但ARC 并不是绝对安全的
         */
        textField.rx.text.orEmpty.asDriver().drive(onNext: {/*[unowned self]*/ [weak self] (text) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
                print("当前输入内容: \(String(describing: text))")
                
                /// 父类的deinit方法不会执行
//                self.label.text = text
                
                /**
                 我们只需将闭包捕获列表定义为弱引用（weak）、或者无主引用（unowned）即可解决问题，这二者的使用场景分别如下：
                 如果捕获（比如 self）可以被设置为 nil，也就是说它可能在闭包前被销毁，那么就要将捕获定义为 weak。
                 如果它们一直是相互引用，即同时销毁的，那么就可以将捕获定义为 unowned。
                 */
                self?.label.text = text
                
                /**
                 如果我们不用 [weak self] 而改用 [unowned self]，返回主页面4秒钟后由于该页早已被销毁，这时访问 label 将会导致异常抛出。
                 当然如果我们把延时去掉的话，使用 [unowned self] 是完全没有问题的。
                 */
            })
        }).disposed(by: disposeBag)
    }
}
