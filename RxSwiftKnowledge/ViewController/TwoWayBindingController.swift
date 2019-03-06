//
//  TwoWayBindingController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/2/28.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

struct UserViewModel {
    let userName = BehaviorRelay(value: "guest")
    
    lazy var userInfo = {
        return self.userName.asObservable().map({$0 == "huang" ? "您是管理员" : "您是普通访客"}).share(replay:1)
    }()
}

class TwoWayBindingController: BaseController {
    
    var userVM = UserViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         在之前的文章样例中，所有的绑定都是单向的。但有时候我们需要实现双向绑定。比如将控件的某个属性值与 ViewModel 里的某个 Subject 属性进行双向绑定：
         这样当 ViewModel 里的值发生改变时，可以同步反映到控件上。
         而如果对控件值做修改，ViewModel 那边值同时也会发生变化。
         */
        
        /**
         一、简单的双向绑定
         （1）页面上方是一个文本输入框，用于填写用户名。它与 VM 里的 username 属性做双向绑定。
         （2）下方的文本标签会根据用户名显示对应的用户信息。（只有 huang 显示管理员，其它都是访客）
         */
        let textField = UITextField(frame: CGRect(x: 10, y: 100, width: view.bounds.size.width - 20, height: 30))
        textField.backgroundColor = UIColor.brown
        view.addSubview(textField)
        
        let label = UILabel(frame: CGRect(x: textField.frame.origin.x, y: textField.frame.maxY + 50, width: textField.bounds.size.width, height: textField.bounds.size.height))
        view.addSubview(label)
        
        /// 将用户名与textField做双向绑定
//        userVM.userName.asObservable().bind(to: textField.rx.text).disposed(by: disposeBag)
//        textField.rx.text.orEmpty.bind(to: userVM.userName).disposed(by: disposeBag)
        
        /// 将用户信息绑定到label上
        userVM.userInfo.bind(to: label.rx.text).disposed(by: disposeBag)
        
        /**
         二、自定义双向绑定操作符（operator）
         1，RxSwift 自带的双向绑定操作符
         （1）如果经常进行双向绑定的话，最好还是自定义一个 operator 方便使用。
         （2）好在 RxSwift 项目文件夹中已经有个现成的（Operators.swift），我们将它复制到我们项目中即可使用。当然如我们想自己写一些其它的双向绑定 operator 也可以参考它。
         */
        /// 将用户名与textField做双向绑定
        _ = textField.rx.textInput <-> userVM.userName
    }
}
