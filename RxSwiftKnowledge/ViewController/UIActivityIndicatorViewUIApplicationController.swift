//
//  UIActivityIndicatorViewUIApplicationController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/2/28.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class UIActivityIndicatorViewUIApplicationController: BaseController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         1，UIActivityIndicatorView（活动指示器）
         UIActivityIndicatorView 又叫状态指示器，它会通过一个旋转的“菊花”来表示当前的活动状态。
         通过开关我们可以控制活动指示器是否显示旋转。
         */
        let switch1 = UISwitch(frame: CGRect(x: 50, y: 100, width: 100, height: 30))
        view.addSubview(switch1)
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.frame = CGRect(x: switch1.frame.maxX + 50, y: switch1.frame.origin.y, width: 30, height: 30)
        view.addSubview(activityIndicator)
        
        switch1.rx.value.bind(to: activityIndicator.rx.isAnimating).disposed(by: disposeBag)
        
        /**
         2，UIApplication
         RxSwift 对 UIApplication 增加了一个名为 isNetworkActivityIndicatorVisible 绑定属性，我们通过它可以设置是否显示联网指示器（网络请求指示器）。
         当开关打开时，顶部状态栏上会有个菊花状的联网指示器。
         当开关关闭时，联网指示器消失。
         */
        switch1.rx.value.bind(to: UIApplication.shared.rx.isNetworkActivityIndicatorVisible).disposed(by: disposeBag)
    }

}
