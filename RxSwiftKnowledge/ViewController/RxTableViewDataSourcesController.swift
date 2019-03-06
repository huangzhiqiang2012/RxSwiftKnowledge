//
//  RxTableViewDataSourcesController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/3/1.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

/// 自定义Section
struct MySection {
    var header: String
    var items:[Item]
}

extension MySection : AnimatableSectionModelType {
    typealias Item = String
    
    var identity:String {
        return header
    }
    
    init(original: MySection, items: [Item]) {
        self = original
        self.items = items
    }
}

class RxTableViewDataSourcesController: BaseController {
    
    let searchBar:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 56))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableView = UITableView(frame: view.frame, style: .plain)
        let identifier = "cell"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        view.addSubview(tableView)
        
        /**
         RxDataSources
         1，RxDataSources 介绍
         （1）如果我们的 tableview 需要显示多个 section、或者更加复杂的编辑功能时，可以借助 RxDataSource 这个第三方库帮我们完成。
         （2）RxDataSource 的本质就是使用 RxSwift 对 UITableView 和 UICollectionView 的数据源做了一层包装。使用它可以大大减少我们的工作量。
         注意：RxDataSources 是以 section 来做为数据结构的。所以不管我们的 tableView 是单分区还是多分区，在使用 RxDataSources 的过程中，都需要返回一个 section 的数组。
         */
        
        /**
         单分区的 TableView
         */
        /// 方式一：使用自带的Section
        /// 初始化数据
//        let items1 = Observable.just([
//            SectionModel(model: "", items: [
//                "UILable的用法",
//                "UIText的用法",
//                "UIButton的用法"
//                ])
//            ])
        
        /// 创建数据源
//        let dataSource1 = RxTableViewSectionedReloadDataSource<SectionModel<String, String>>(configureCell: { (dataSource, tableView, indexPath, element) -> UITableViewCell in
//            let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
//            cell.textLabel?.text = "\(indexPath.row): \(element)"
//            return cell
//        })
        
        /// 绑定单元格数据
//        items1.bind(to: tableView.rx.items(dataSource: dataSource1)).disposed(by: disposeBag)
        
        /// 方式二：使用自定义的Section
        /// 初始化数据
//        let items2 = Observable.just([
//            MySection(header: "", items:[
//                "UILable的用法",
//                "UIText的用法",
//                "UIButton的用法"
//                ])
//            ])
        
        /// 创建数据源
//        let dataSource2 = RxTableViewSectionedAnimatedDataSource<MySection>(configureCell: { (dataSource, tableView, indexPath, element) -> UITableViewCell in
//            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: .default, reuseIdentifier: identifier)
//            cell.textLabel?.text = "\(indexPath.row): \(element)"
//            return cell
//            })
        
        /// 绑定单元格数据
//        items2.bind(to: tableView.rx.items(dataSource: dataSource2)).disposed(by: disposeBag)
        
        /**
         多分区的 UITableView
         */
        /// 方式一：使用自带的Section
        /// 初始化数据
//        let items3 = Observable.just([
//            SectionModel(model: "基本控件", items: [
//                "UILable的用法",
//                "UIText的用法",
//                "UIButton的用法"
//                ]),
//            SectionModel(model: "高级控件", items: [
//                "UITableView的用法",
//                "UICollectionViews的用法"
//                ])
//            ])
        
        /// 创建数据源
//        let dataSource3 = RxTableViewSectionedReloadDataSource
//            <SectionModel<String, String>>(configureCell: {
//                (dataSource, tableView, indexPath, element) in
//                let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
//                cell.textLabel?.text = "\(indexPath.row)：\(element)"
//                return cell
//            })
        
        /// 设置分区头标题
//        dataSource3.titleForHeaderInSection = { dataSource, index in
//            return dataSource.sectionModels[index].model
//        }
        
        /// 绑定单元格数据
        /// 注:需要dataSource3各种设置都设置完才能调用该方法,不然会崩溃,比如 /// 设置分区头标题的方法在 此方法后面才调用,就会崩溃
//        items3.bind(to: tableView.rx.items(dataSource: dataSource3)).disposed(by: disposeBag)
        
        /// 方式二：使用自定义的Section
        /// 初始化数据
//        let items4 = Observable.just([
//            MySection(header: "基本控件", items: [
//                "UILable的用法",
//                "UIText的用法",
//                "UIButton的用法"
//                ]),
//            MySection(header: "高级控件", items: [
//                "UITableView的用法",
//                "UICollectionViews的用法"
//                ])
//            ])
        
        /// 创建数据源
//        let dataSource4 = RxTableViewSectionedAnimatedDataSource
//            <MySection>(configureCell: {
//                (dataSource, tableView, indexPath, element) in
//                let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: .default, reuseIdentifier: identifier)
//                cell.textLabel?.text = "\(indexPath.row)：\(element)"
//                return cell
//            },
//
//            /// 设置分区头标题
//            titleForHeaderInSection: { ds, index in
//                return ds.sectionModels[index].header
//            }
//        )
        
        /// 绑定单元格数据
//        items4.bind(to: tableView.rx.items(dataSource: dataSource4)).disposed(by: disposeBag)
        
        /**
         很多情况下，表格里的数据不是一开始就准备好的、或者固定不变的。可能我们需要先向服务器请求数据，再将获取到的内容显示在表格中。
         要重新加载表格数据，过去的做法就是调用 tableView 的 reloadData() 方法。介绍在使用 RxSwift 的情况下，应该如何刷新数据。
         */
        
        /**
         三、数据刷新
         1，效果图
         （1）界面初始化完毕后，tableView 默认会加载一些随机数据。
         （2）点击右上角的刷新按钮，tableView 会重新加载并显示一批新数据。
         （3）为方便演示，每次获取数据不是真的去发起网络请求。而是在本地生成后延迟 2 秒返回，模拟这种异步请求的情况。
         */
        let refreshButton = UIBarButtonItem(title: "刷新", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = refreshButton
        
        /// 随机的表格数据
//        let randomResult1 = refreshButton.rx.tap.asObservable()
//            .throttle(1, scheduler: MainScheduler.instance)  /// 在主线程中操作，1秒内值若多次改变，取最后一次
//            .startWith(())  /// 加这个为了让一开始就能自动请求一次数据
//            .flatMapLatest(getRandomResult) /// flatMapLatest 的作用是当在短时间内（上一个请求还没回来）连续点击多次“刷新”按钮，虽然仍会发起多次请求，但表格只会接收并显示最后一次请求。避免表格出现连续刷新的现象。
//            .share(replay:1)
        
        /// 创建数据源
//        let dataSource5 = RxTableViewSectionedReloadDataSource<SectionModel<String, Int>>(configureCell: { (dataSource, tableView, indexPath, element) -> UITableViewCell in
//            let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
//            cell.textLabel?.text = "条目\(indexPath.row)：\(element)"
//            return cell
//        })
        
        /// 绑定单元格数据
//        randomResult1.bind(to: tableView.rx.items(dataSource: dataSource5)).disposed(by: disposeBag)
        
        /**
         停止数据请求
         在实际项目中我们可能会需要对一个未完成的网络请求进行中断操作。比如切换页面或者分类时，如果上一次的请求还未完成就要将其取消掉。下面通过样例演示如何实现该功能。
         这里我们在前面样例的基础上增加了个“停止”按钮。当发起请求且数据还未返回时（2 秒内），按下该按钮后便会停止对结果的接收处理，即表格不加载显示这次的请求数据。
         */
//        let stopButton = UIBarButtonItem(title: "停止", style: .plain, target: nil, action: nil)
//        navigationItem.leftBarButtonItem = stopButton
        
        /// 随机的表格数据
//        let randomResult2 = refreshButton.rx.tap.asObservable()
//            .throttle(1, scheduler: MainScheduler.instance)  /// 在主线程中操作，1秒内值若多次改变，取最后一次
//            .startWith(())  /// 加这个为了让一开始就能自动请求一次数据
//            .flatMapLatest {
//                self.getRandomResult().takeUntil(stopButton.rx.tap)
//            } /// flatMapLatest 的作用是当在短时间内（上一个请求还没回来）连续点击多次“刷新”按钮，虽然仍会发起多次请求，但表格只会接收并显示最后一次请求。避免表格出现连续刷新的现象。
//            .share(replay:1)
        
        /// 创建数据源
//        let dataSource6 = RxTableViewSectionedReloadDataSource<SectionModel<String, Int>>(configureCell: { (dataSource, tableView, indexPath, element) -> UITableViewCell in
//            let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
//            cell.textLabel?.text = "条目\(indexPath.row)：\(element)"
//            return cell
//        })
        
        /// 绑定单元格数据
//        randomResult2.bind(to: tableView.rx.items(dataSource: dataSource6)).disposed(by: disposeBag)
        
        /**
         数据搜索过滤
         我们在 tableView 的表头上增加了一个搜索框。tableView 会根据搜索框里输入的内容实时地筛选并显示出符合条件的数据（包含有输入文字的数据条目）
         注意：这个实时搜索是对已获取到的数据进行过滤，即每次输入文字时不会重新发起请求。
         */
        tableView.tableHeaderView = searchBar
        
        let randomResult3 = refreshButton.rx.tap.asObservable()
            .throttle(1, scheduler: MainScheduler.instance)  /// 在主线程中操作，1秒内值若多次改变，取最后一次
            .startWith(())  /// 加这个为了让一开始就能自动请求一次数据
            .flatMapLatest(getRandomResult)  /// flatMapLatest 的作用是当在短时间内（上一个请求还没回来）连续点击多次“刷新”按钮，虽然仍会发起多次请求，但表格只会接收并显示最后一次请求。避免表格出现连续刷新的现象。
            .flatMap(filterResult) /// 筛选数据
            .share(replay:1)
        
        /// 创建数据源
        let dataSource7 = RxTableViewSectionedReloadDataSource<SectionModel<String, Int>>(configureCell: { (dataSource, tableView, indexPath, element) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
            cell.textLabel?.text = "条目\(indexPath.row)：\(element)"
            return cell
        })
        
        /// 绑定单元格数据
        randomResult3.bind(to: tableView.rx.items(dataSource: dataSource7)).disposed(by: disposeBag)
    }
}

extension RxTableViewDataSourcesController {
    fileprivate func getRandomResult() -> Observable<[SectionModel<String, Int>]> {
        print("正在请求数据......")
        let items = (0..<5).map { _ in
            Int(arc4random())
        }
        let observable = Observable.just([SectionModel(model: "S", items: items)])
        return observable.delay(2, scheduler: MainScheduler.instance)
    }
    
    fileprivate func filterResult(data:[SectionModel<String, Int>]) -> Observable<[SectionModel<String, Int>]> {
        return searchBar.rx.text.orEmpty
//        .debounce(0.5, scheduler: MainScheduler.instance) /// 只有间隔超过0.5秒才发送
            .flatMapLatest({ (query) -> Observable<[SectionModel<String, Int>]> in
                print("正在筛选数据（条件为：\(query)）")
                
                /// 输入条件为空，则直接返回原始数据
                if query.isEmpty {
                    return Observable.just(data)
                }
                var newData:[SectionModel<String, Int>] = []
                for sectionModel in data {
                    let items = sectionModel.items.filter({"\($0)".contains(query)})
                    newData.append(SectionModel(model: sectionModel.model, items: items))
                }
                return Observable.just(newData)
            })
    }
}
