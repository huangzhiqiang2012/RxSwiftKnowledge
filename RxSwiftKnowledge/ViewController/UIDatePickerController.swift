//
//  UIDatePickerController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/3/1.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class UIDatePickerController: BaseController {
    
    fileprivate lazy var dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        return formatter
    }()
    
    /// 剩余时间（必须为 60 的整数倍，比如设置为100，值自动变为 60）
    let leftTime = Variable(TimeInterval(180))
    
    /// 当前倒计时是否结束
    let countDownStopped = Variable(true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let datePicker = UIDatePicker(frame: CGRect(x: 10, y: 100, width: view.bounds.size.width - 20, height: 100))
        view.addSubview(datePicker)
        
        let label = UILabel(frame: CGRect(x: datePicker.frame.origin.x, y: datePicker.frame.maxY + 50, width: datePicker.bounds.size.width, height: datePicker.bounds.size.height))
        label.textAlignment = .center
        view.addSubview(label)
        
        /**
         UIDatePicker
         1，日期选择响应
         当日期选择器里面的时间改变后，将时间格式化显示到 label 中。
         */
        datePicker.rx.date.map { [weak self] in
            if let self = self {
                return "当前选择时间: " + self.dateFormatter.string(from: $0)
            }
            return ""
        }.bind(to: label.rx.text).disposed(by: disposeBag)
        
        /**
         2，倒计时功能
         通过上方的 datepicker 选择需要倒计时的时间后，点击“开始”按钮即可开始倒计时。
         倒计时过程中，datepicker 和按钮都不可用。且按钮标题变成显示倒计时剩余时间。
         */
        let ctimer = UIDatePicker(frame: CGRect(x: datePicker.frame.origin.x, y: label.frame.maxY + 50, width: datePicker.bounds.size.width, height: datePicker.bounds.size.height))
        ctimer.datePickerMode = .countDownTimer
        view.addSubview(ctimer)
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: ctimer.frame.origin.x, y: ctimer.frame.maxY + 50, width: ctimer.bounds.size.width, height: 30)
        button.setTitleColor(UIColor.red, for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .disabled)
        view.addSubview(button)
        
        /// 剩余时间与ctimer做双向绑定
        DispatchQueue.main.async {
            ctimer.rx.countDownDuration.asObservable().bind(to:self.leftTime).disposed(by: self.disposeBag)
            self.leftTime.asObservable().bind(to: ctimer.rx.countDownDuration).disposed(by: self.disposeBag)
//            _ = ctimer.rx.countDownDuration <-> self.leftTime
        }
        
        /// 绑定button标题
        Observable.combineLatest(leftTime.asObservable(), countDownStopped.asObservable()) {
            leftTimeValue, countDownStoppedValue in
            
            /// 根据当前的状态设置按钮的标题
            if countDownStoppedValue {
                return "开始"
            }
            return "倒计时开始, 还有 \(Int(leftTimeValue)) 秒..."
        }.bind(to: button.rx.title()).disposed(by: disposeBag)
        
        /// 绑定button和datepicker状态（在倒计过程中，按钮和时间选择组件不可用）
        countDownStopped.asDriver().drive(ctimer.rx.isEnabled).disposed(by: disposeBag)
        countDownStopped.asDriver().drive(button.rx.isEnabled).disposed(by: disposeBag)
        
        /// 按钮点击响应
        button.rx.tap.bind { [weak self] in
            self?.startClicked()
        }.disposed(by: disposeBag)
    }
}

extension UIDatePickerController {
    fileprivate func startClicked() {
        
        /// 开始倒计时
        countDownStopped.value = false
        
        /// 创建一个计时器
        Observable<Int>.interval(1, scheduler: MainScheduler.instance).takeUntil(countDownStopped.asObservable().filter {$0})  /// 倒计时结束时停止计时器
            .subscribe { (event) in
                
                /// 每次剩余时间减1
                self.leftTime.value -= 1
                
                /// 如果剩余时间小于等于0
                if self.leftTime.value == 0 {
                    print("倒计时结束!")
                    
                    /// 结束倒计时
                    self.countDownStopped.value = true
                    
                    /// 重制时间
                    self.leftTime.value = 180
                }
        }.disposed(by: disposeBag)
    }
}
