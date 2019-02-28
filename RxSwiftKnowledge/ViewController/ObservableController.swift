//
//  ObservableController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/2/28.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ObservableController: BaseController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Observable 介绍
        /**
         1，Observable<T>
         Observable<T> 这个类就是Rx 框架的基础，我们可以称它为可观察序列。它的作用就是可以异步地产生一系列的 Event（事件），即一个 Observable<T> 对象会随着时间推移不定期地发出 event(element : T) 这样一个东西。
         而且这些 Event 还可以携带数据，它的泛型 <T> 就是用来指定这个Event携带的数据的类型。
         有了可观察序列，我们还需要有一个Observer（订阅者）来订阅它，这样这个订阅者才能收到 Observable<T> 不时发出的 Event。
         */
        
        /**
         2，Event
         查看 RxSwift 源码可以发现，事件 Event 的定义如下：
         
         public enum Event<Element> {
         /// Next element is produced.
         case next(Element)
         
         /// Sequence terminated with an error.
         case error(Swift.Error)
         
         /// Sequence completed successfully.
         case completed
         }
         
         可以看到 Event 就是一个枚举，也就是说一个 Observable 是可以发出 3 种不同类型的  Event 事件：
         next：next事件就是那个可以携带数据 <T> 的事件，可以说它就是一个“最正常”的事件。
         error：error 事件表示一个错误，它可以携带具体的错误内容，一旦 Observable 发出了 error event，则这个 Observable 就等于终止了，以后它再也不会发出 event 事件了。
         completed：completed 事件表示Observable 发出的事件正常地结束了，跟 error 一样，一旦 Observable 发出了 completed event，则这个 Observable 就等于终止了，以后它再也不会发出 event 事件了。
         */
        
        /**
         3，Observable 与 Sequence比较
         （1）为更好地理解，我们可以把每一个 Observable 的实例想象成于一个 Swift 中的 Sequence：
         即一个 Observable（ObservableType）相当于一个序列 Sequence（SequenceType）。
         ObservableType.subscribe(_:)方法其实就相当于 SequenceType.generate()
         
         （2）但它们之间还是有许多区别的：
         Swift 中的 SequenceType 是同步的循环，而 Observable是异步的。
         Observable 对象会在有任何 Event 时候，自动将 Event作为一个参数通过ObservableType.subscribe(_:)发出，并不需要使用 next方法。
         */
        
        // MARK: 创建Observable 序列
        /**
         1，just() 方法
         （1）该方法通过传入一个默认值来初始化。
         （2）下面样例我们显式地标注出了 observable 的类型为 Observable<Int>，即指定了这个 Observable所发出的事件携带的数据类型必须是 Int 类型的。
         */
        _ = Observable<Int>.just(5)
        
        /**
         2，of() 方法
         （1）该方法可以接受可变数量的参数（必需要是同类型的）
         （2）下面样例中我没有显式地声明出 Observable 的泛型类型，Swift 也会自动推断类型。
         */
        _ = Observable.of("A", "B", "C")
        
        /**
         3，from() 方法
         （1）该方法需要一个数组参数。
         （2）下面样例中数据里的元素就会被当做这个 Observable 所发出 event携带的数据内容，最终效果同上面 of()样例是一样的。
         */
        _ = Observable.from(["A", "B", "C"])
        
        /**
         4，empty() 方法
         该方法创建一个空内容的 Observable 序列。
         */
        _ = Observable<Int>.empty()
        
        /**
         5，never() 方法
         该方法创建一个永远不会发出 Event（也不会终止）的 Observable 序列。
         */
        _ = Observable<Int>.never()
        
        /**
         6，error() 方法
         该方法创建一个不做任何操作，而是直接发送一个错误的 Observable 序列。
         */
        enum MyError : Error {
            case A
            case B
        }
        _ = Observable<Int>.error(MyError.A)
        
        /**
         7，range() 方法
         （1）该方法通过指定起始和结束数值，创建一个以这个范围内所有值作为初始值的Observable序列。
         （2）下面样例中，两种方法创建的 Observable 序列都是一样的。
         */
        _ = Observable.range(start: 1, count: 5)
        _ = Observable.of(1, 2, 3, 4, 5)
        
        /**
         8，repeatElement() 方法
         该方法创建一个可以无限发出给定元素的 Event的 Observable 序列（永不终止）。
         */
        _ = Observable.repeatElement(1)
        
        /**
         9，generate() 方法
         （1）该方法创建一个只有当提供的所有的判断条件都为 true 的时候，才会给出动作的  Observable 序列。
         （2）下面样例中，两种方法创建的 Observable 序列都是一样的。
         */
        _ = Observable.generate(
            initialState: 0,
            condition: { $0 <= 10},
            iterate: {$0  + 2})
        _ = Observable.of(0, 2, 4, 6, 8, 10)
        
        /**
         10，create() 方法
         （1）该方法接受一个 block 形式的参数，任务是对每一个过来的订阅进行处理。
         （2）下面是一个简单的样例。为方便演示，这里增加了订阅相关代码。
         */
        ///这个block有一个回调参数observer就是订阅这个Observable对象的订阅者
        ///当一个订阅者订阅这个Observable对象的时候，就会将订阅者作为参数传入这个block来执行一些内容
        let observable10 = Observable<String>.create { (observer) -> Disposable in
            observer.onNext("hangge.com")
            observer.onCompleted()
            return Disposables.create()
        }
        _ = observable10.subscribe {
            print($0)
        }
        
        /**
         11，deferred() 方法
         该个方法相当于是创建一个 Observable 工厂，通过传入一个 block 来执行延迟 Observable序列创建的行为，而这个 block 里就是真正的实例化序列对象的地方。
         */
        ///用于标记是奇数、还是偶数
        var isOdd = true
        
        ///使用deferred()方法延迟Observable序列的初始化，通过传入的block来实现Observable序列的初始化并且返回。
        let factory : Observable<Int> = Observable.deferred {
            
            ///让每次执行这个block时候都会让奇、偶数进行交替
            isOdd = !isOdd
            
            ///根据isOdd参数，决定创建并返回的是奇数Observable、还是偶数Observable
            return isOdd ? Observable.of(1, 3, 5, 7) : Observable.of(2, 4, 6, 8)
        }
        
        ///第1次订阅测试
        _ = factory.subscribe { (event) in
            print("\(isOdd)", event)
        }
        
        ///第2次订阅测试
        _ = factory.subscribe { (event) in
            print("\(isOdd)", event)
        }
        
        /**
         12，interval() 方法
         （1）这个方法创建的 Observable 序列每隔一段设定的时间，会发出一个索引数的元素。而且它会一直发送下去。
         （2）下面方法让其每 1 秒发送一次，并且是在主线程（MainScheduler）发送。
         */
        //        let observable12 = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        //        _ = observable12.subscribe { (event) in
        //            print(event)
        //        }
        
        /**
         13，timer() 方法
         （1）这个方法有两种用法，一种是创建的 Observable序列在经过设定的一段时间后，产生唯一的一个元素。
         （2）另一种是创建的 Observable 序列在经过设定的一段时间后，每隔一段时间产生一个元素。
         */
        ///5秒种后发出唯一的一个元素0
        //        let observable131 = Observable<Int>.timer(5, scheduler: MainScheduler.instance)
        //        _ = observable131.subscribe { (event) in
        //            print(event)
        //        }
        //
        //        ///延时5秒种后，每隔1秒钟发出一个元素
        //        let observable132 = Observable<Int>.timer(5, period: 1, scheduler: MainScheduler.instance)
        //        _ = observable132.subscribe({ (event) in
        //            print(event)
        //        })
        
        // MARK: 订阅 Observable
        /**
         有了 Observable，我们还要使用 subscribe() 方法来订阅它，接收它发出的 Event。
         */
        /**
         第一种用法：
         （1）我们使用 subscribe() 订阅了一个Observable 对象，该方法的 block 的回调参数就是被发出的 event 事件，我们将其直接打印出来。
         运行结果如下，可以看到：
         初始化 Observable 序列时设置的默认值都按顺序通过 .next 事件发送出来。
         当 Observable 序列的初始数据都发送完毕，它还会自动发一个 .completed 事件出来。
         */
        let observable21 = Observable.of("A", "B", "C")
        _ = observable21.subscribe({ (event) in
            print(event)
            
            ///如果想要获取到这个事件里的数据，可以通过 event.element 得到。
            print(event.element as Any)
        })
        
        /**
         第二种用法：
         （1）RxSwift 还提供了另一个 subscribe方法，它可以把 event 进行分类：
         通过不同的 block 回调处理不同类型的 event。（其中 onDisposed 表示订阅行为被 dispose 后的回调，这个我后面会说）
         同时会把 event 携带的数据直接解包出来作为参数，方便我们使用。
         （2）subscribe() 方法的 onNext、onError、onCompleted 和 onDisposed 这四个回调 block 参数都是有默认值的，即它们都是可选的。所以我们也可以只处理 onNext而不管其他的情况。
         */
        let observable22 = Observable.of("A", "B", "C")
        _ = observable22.subscribe(onNext: { (element) in
            print(element)
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
            print("Completed")
        }, onDisposed: {
            print("Disposed")
        })
        _ = observable22.subscribe(onNext: { (element) in
            print(element)
        })
        
        // MARK: 监听事件的生命周期
        /**
         doOn 介绍
         （1）我们可以使用 doOn 方法来监听事件的生命周期，它会在每一次事件发送前被调用。
         （2）同时它和 subscribe 一样，可以通过不同的block 回调处理不同类型的 event。比如：
         do(onNext:)方法就是在subscribe(onNext:) 前调用
         而 do(onCompleted:) 方法则会在 subscribe(onCompleted:) 前面调用。
         */
        let observable3 = Observable.of("A", "B", "C")
        _ = observable3.do(onNext: { (element) in
            print("Intercepted Next：", element)
        }, onError: { (error) in
            print("Intercepted Error：", error)
        }, onCompleted: {
            print("Intercepted Completed")
        }, onDispose: {
            print("Intercepted Disposed")
        }).subscribe(onNext: { (element) in
            print(element)
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
            print("Completed")
        }, onDisposed: {
            print("Disposed")
        })
        
        // MARK: Observable 的销毁（Dispose）
        /**
         1，Observable 从创建到终结流程
         （1）一个 Observable 序列被创建出来后它不会马上就开始被激活从而发出 Event，而是要等到它被某个人订阅了才会激活它。
         （2）而 Observable 序列激活之后要一直等到它发出了.error或者 .completed的 event 后，它才被终结。
         2，dispose() 方法
         （1）使用该方法我们可以手动取消一个订阅行为。
         （2）如果我们觉得这个订阅结束了不再需要了，就可以调用 dispose()方法把这个订阅给销毁掉，防止内存泄漏。
         （3）当一个订阅行为被dispose 了，那么之后 observable 如果再发出 event，这个已经 dispose 的订阅就收不到消息了。
         */
        let observable4 = Observable.of("A", "B", "C")
        let subscription4 = observable4.subscribe { (event) in
            print(event)
        }
        subscription4.dispose()
        
        /**
         3，DisposeBag
         除了 dispose()方法之外，我们更经常用到的是一个叫 DisposeBag 的对象来管理多个订阅行为的销毁：
         我们可以把一个 DisposeBag对象看成一个垃圾袋，把用过的订阅行为都放进去。
         而这个DisposeBag 就会在自己快要dealloc 的时候，对它里面的所有订阅行为都调用 dispose()方法。
         */
        
        let observable41 = Observable.of("1", "2", "3")
        observable41.subscribe { (event) in
            print(event)
            }.disposed(by: disposeBag)
        let observable42 = Observable.of("4", "5", "6")
        observable42.subscribe { (event) in
            print(event)
            }.disposed(by: disposeBag)
    }
}
