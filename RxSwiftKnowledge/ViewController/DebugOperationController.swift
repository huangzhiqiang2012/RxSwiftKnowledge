//
//  DebugOperationController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/2/28.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class DebugOperationController: BaseController {    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         调试操作
         1，debug
         我们可以将 debug 调试操作符添加到一个链式步骤当中，这样系统就能将所有的订阅者、事件、和处理等详细信息打印出来，方便我们开发调试。
         debug() 方法还可以传入标记参数，这样当项目中存在多个 debug 时可以很方便地区分出来。
         */
        //        _ = Observable.of("2", "3").startWith("1").debug().subscribe(onNext: {print($0)}).disposed(by: disposeBag)
        
        _ = Observable.of("2", "3").startWith("1").debug("调试1").subscribe(onNext: {print($0)}).disposed(by: disposeBag)
        
        /**
         2，RxSwift.Resources.total
         通过将 RxSwift.Resources.total 打印出来，我们可以查看当前 RxSwift 申请的所有资源数量。这个在检查内存泄露的时候非常有用。
         
         注: 同时必须在Podfile中开启调试模式
         post_install do |installer|
         installer.pods_project.targets.each do |target|
         if target.name == 'RxSwift'
         target.build_configurations.each do |config|
         if config.name == 'Debug'
         config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
         end
         end
         end
         end
         end
         */
        print(RxSwift.Resources.total)
        
        let disposeBag1 = DisposeBag()
        
        print(RxSwift.Resources.total)
        
        _ = Observable.of("BBB", "CCC").startWith("AAA").subscribe(onNext: {print($0)}).disposed(by: disposeBag1)
        
        print(RxSwift.Resources.total)
    }
}
