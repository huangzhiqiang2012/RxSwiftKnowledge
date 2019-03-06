//
//  UISliderUIStepperController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/2/28.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class UISliderUIStepperController: BaseController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         1，UISlider（滑块）
         当我们拖动滑块时，在控制台中实时输出 slider 当前值。
         */
        let slider = UISlider(frame: CGRect(x: (view.bounds.size.width - 100) * 0.5, y: 100, width: 100, height: 30))
        slider.minimumValue = 1
        slider.maximumValue = 100
        view.addSubview(slider)
        slider.rx.value.asObservable().subscribe(onNext: {
            print("slider 当前值为: \($0)")
        }).disposed(by: disposeBag)
        
        /**
         2，UIStepper（步进器）
         下面样例当 stepper 值改变时，在控制台中实时输出当前值。
         */
        let stepper = UIStepper(frame: CGRect(x: slider.frame.origin.x, y: slider.frame.maxY + 50, width: slider.bounds.size.width, height: slider.bounds.size.height))
        view.addSubview(stepper)
        stepper.rx.value.asObservable().subscribe(onNext: {
            print("stepper 当前值为: \($0)")
        }).disposed(by: disposeBag)
        
        /**
         下面样例我们使用滑块（slider）来控制 stepper 的步长。
         */
        slider.rx.value.map { Double($0)  /// 由于slider值为Float类型，而stepper的stepValue为Double类型，因此需要转换
        }.bind(to: stepper.rx.stepValue).disposed(by: disposeBag)
    }
}
