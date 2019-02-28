//
//  ObserverController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/2/28.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ObserverController: BaseController {

    fileprivate lazy var label:UILabel = {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
        label.textColor = UIColor.blue
        label.font = UIFont.systemFont(ofSize: 15)
        view.addSubview(label)
        label.center = view.center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: 观察者（Observer）介绍
        /**
         观察者（Observer）的作用就是监听事件，然后对这个事件做出响应。或者说任何响应事件的行为都是观察者。比如：
         当我们点击按钮，弹出一个提示框。那么这个“弹出一个提示框”就是观察者Observer<Void>
         当我们请求一个远程的json 数据后，将其打印出来。那么这个“打印 json 数据”就是观察者 Observer<JSON>
         */
        
        // MARK: 直接在 subscribe、bind 方法中创建观察者
        /**
         1，在 subscribe 方法中创建
         创建观察者最直接的方法就是在 Observable 的 subscribe 方法后面描述当事件发生时，需要如何做出响应。
         */
        let observable2 = Observable.of("A", "B", "C")
        _ = observable2.subscribe(onNext: { element in
            print(element)
        }, onError: { error in
            print(error)
        }, onCompleted: {
            print("Completed")
        })
        
        /**
         2，在 bind 方法中创建
         （1）下面代码我们创建一个定时生成索引数的 Observable 序列，并将索引数不断显示在 label 标签上：
         */
        
        //        let observable22 = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        //        _ = observable22.map {"当前索引数: \($0)"}.bind {[weak self] (text) in
        //            self?.label.text = text
        //        }
        
        // MARK: 使用 AnyObserver 创建观察者
        /**
         AnyObserver 可以用来描叙任意一种观察者。
         1，配合 subscribe 方法使用
         */
        let observable31 = Observable.of("A", "B", "C")
        let observer31:AnyObserver<String> = AnyObserver { (event) in
            switch event {
            case .next(let data):
                print(data)
            case .error(let error):
                print(error)
            case .completed:
                print("Completed")
            }
        }
        _ = observable31.subscribe(observer31)
        
        /**
         2，配合 bindTo 方法使用
         也可配合 Observable 的数据绑定方法（bindTo）使用
         */
        //        let observable32 = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        //        let observer32:AnyObserver<String> = AnyObserver {[weak self] (event) in
        //            switch event {
        //            case .next(let text):
        //                self?.label.text = text
        //            default:break
        //            }
        //        }
        //        _ = observable32.map {"当前索引数：\($0 )"}.bind(to: observer32)
        
        // MARK: 使用 Binder 创建观察者
        /**
         1，基本介绍
         （1）相较于AnyObserver 的大而全，Binder 更专注于特定的场景。Binder 主要有以下两个特征：
         不会处理错误事件
         确保绑定都是在给定 Scheduler 上执行（默认 MainScheduler）
         （2）一旦产生错误事件，在调试环境下将执行 fatalError，在发布环境下将打印错误信息。
         2，使用样例
         （1）在上面序列数显示样例中，label 标签的文字显示就是一个典型的 UI 观察者。它在响应事件时，只会处理 next 事件，而且更新 UI 的操作需要在主线程上执行。那么这种情况下更好的方案就是使用 Binder。
         （2）上面的样例我们改用 Binder 会简单许多：
         */
        //        let observer4 : Binder<String> = Binder(label) {(view, text) in
        //            view.text = text
        //        }
        //        let observable4 = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        //        _ = observable4.map {"当前索引数：\($0 )"}.bind(to: observer4)
        
        // MARK: 自定义可绑定属性
        /**
         有时我们想让 UI 控件创建出来后默认就有一些观察者，而不必每次都为它们单独去创建观察者。比如我们想要让所有的 UIlabel 都有个 fontSize 可绑定属性，它会根据事件值自动改变标签的字体大小。
         */
        //        label.font = UIFont.systemFont(ofSize: 8)
        //        label.text = "字体会变大的"
        //        let observable5 = Observable<Int>.interval(0.5, scheduler: MainScheduler.instance)
        //        _ = observable5.map {CGFloat($0)}.bind(to:label.fontSize)       /// 系统扩展方法
        //        _ = observable5.map {CGFloat($0)}.bind(to: label.rx.fontSize)   /// Reactive类进行扩展
        
        // MARK: RxSwift 自带的可绑定属性（UI 观察者）
        /**
         （1）其实 RxSwift 已经为我们提供许多常用的可绑定属性。比如 UILabel 就有 text 和 attributedText 这两个可绑定属性。
         （2）那么上文那个定时显示索引数的样例，我们其实不需要自定义 UI 观察者，直接使用 RxSwift 提供的绑定属性即可。
         */
        let observable6 = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        _ = observable6.map {"当前索引数: \($0)"}.bind(to: label.rx.text)
    }
}

// MARK: 系统扩展方法
extension UILabel {
    public var fontSize: Binder<CGFloat> {
        return Binder(self) { label, fontSize in
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
}

// MARK: 对Reactive类进行扩展
extension Reactive where Base: UILabel {
    public var fontSize: Binder<CGFloat> {
        return Binder(self.base) { label, fontSize in
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
    
    public var text:Binder<String?> {
        return Binder(self.base) { label, text in
            label.text = text
        }
    }
    
    public var attributedText:Binder<NSAttributedString?> {
        return Binder(self.base) { label, text in
            label.attributedText = text
        }
    }
}

