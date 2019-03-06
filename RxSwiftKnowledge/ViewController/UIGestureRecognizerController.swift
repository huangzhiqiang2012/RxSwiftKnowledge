//
//  UIGestureRecognizerController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/3/1.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit

class UIGestureRecognizerController: BaseController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         UIGestureRecognizer
         RxCocoa 同样对 UIGestureRecognizer 进行了扩展，并增加相关的响应方法。下面以滑动手势为例，其它手势用法也是一样的。
         */
        /***/
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = .up
        view.addGestureRecognizer(swipe)
        
        /// 第一种响应回调的写法
//        swipe.rx.event.subscribe(onNext: {[weak self] (recognizer) in
//            let point = recognizer.location(in: recognizer.view)
//            self?.showAlert(title: "向上滑动", message: "x:\(point.x) y:\(point.y)")
//        }).disposed(by: disposeBag)
        
        /// 第二种响应回调的写法
        swipe.rx.event.bind { [weak self] recognizer in
            let point = recognizer.location(in: recognizer.view)
            self?.showAlert(title: "向上滑动", message: "x:\(point.x) y:\(point.y)")
        }.disposed(by: disposeBag)
    }
}

extension UIGestureRecognizerController {
    fileprivate func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .cancel))
        self.present(alert, animated: true)
    }
}
