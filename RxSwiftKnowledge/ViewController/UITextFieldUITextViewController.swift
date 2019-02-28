//
//  UITextFieldUITextViewController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/2/28.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class UITextFieldUITextViewController: BaseController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let textField = UITextField(frame: CGRect(x: 16, y: 100, width: UIScreen.main.bounds.size.width - 32, height: 30))
        textField.backgroundColor = UIColor.blue
        view.addSubview(textField)
        
        /**
         二、UITextField 与 UITextView
         1，监听单个 textField 内容的变化（textView 同理）
         （1）下面样例中我们将 textField 里输入的内容实时地显示到控制台中。
         注意：.orEmpty 可以将 String? 类型的 ControlProperty 转成 String，省得我们再去解包。
         */
        textField.rx.text.orEmpty.asObservable().subscribe(onNext: {print("您输入的是: \($0)")}).disposed(by: disposeBag)
    }
}
