//
//  MJRefreshController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/3/7.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/// 对MJRefreshComponent增加rx扩展
extension Reactive where Base : MJRefreshComponent {
    
    /// 正在刷新事件
    var refreshing : ControlEvent<Void> {
        let source : Observable<Void> = Observable.create { [weak control = self.base] observer in
            if let control = control {
                control.refreshingBlock = {
                    observer.on(.next(()))
                }
            }
            return Disposables.create()
        }
        return ControlEvent(events: source)
    }
    
    /// 停止刷新
    var enRefreshing : Binder<Bool> {
        return Binder(base) { refresh, isEnd in
            if isEnd {
                refresh.endRefreshing()
            }
        }
    }
}

/// 网络请求服务
class MJRefreshNetworkService {
    
    /// 获取随机数据
    func getRandomResult() -> Observable<[String]> {
        print("--__--|| 正在请求数据......")
        let items = (0 ..< 15).map { _ in
            "随机数据\(Int(arc4random()))"
        }
        let observable = Observable.just(items)
        return observable.delay(1, scheduler: MainScheduler.instance)
    }
}

class MJRefreshViewModel {
    
    /// 表格数据序列
    let tableData = BehaviorRelay<[String]>(value: [])
    
    /// 停止头部刷新状态序列
    let endHeaderRefreshing: Observable<Bool>
    
    /// 停止尾部刷新状态序列
    let endFooterRefreshing: Observable<Bool>
    
    /// ViewModel初始化（根据输入实现对应的输出）
    init(input: (
              headerRefresh: Observable<Void>,
              footerRefresh: Observable<Void>),
        dependency: (
              disposeBag: DisposeBag,
              networkService: MJRefreshNetworkService)) {
        
        /// 下拉结果序列
        let headerRefreshData = input.headerRefresh
            .startWith(()) /// 初始化时会先自动加载一次数据
            .flatMapLatest { _ in dependency.networkService.getRandomResult().takeUntil(input.footerRefresh)}.share(replay: 1)
        
        /// 上拉结果序列
        let footerRefreshData = input.footerRefresh.flatMapLatest { _ in dependency.networkService.getRandomResult().takeUntil(input.headerRefresh)}.share(replay: 1)
        
        /// 生成停止头部刷新状态序列
        self.endHeaderRefreshing = Observable.merge(headerRefreshData.map { _ in true}, input.footerRefresh.map { _ in true})
        
        /// 生成停止尾部刷新状态序列
        self.endFooterRefreshing = Observable.merge(footerRefreshData.map { _ in true}, input.headerRefresh.map { _ in true})
        
        /// 下拉刷新时，直接将查询到的结果替换原数据
        headerRefreshData.subscribe(onNext: { (items) in
            self.tableData.accept(items)
        }).disposed(by: dependency.disposeBag)
        
        /// 上拉加载时，将查询到的结果拼接到原数据底部
        footerRefreshData.subscribe(onNext: { (items) in
            self.tableData.accept(self.tableData.value + items)
        }).disposed(by: dependency.disposeBag)
    }
}

class MJRefreshController: BaseController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height - UIApplication.shared.statusBarFrame.size.height - (navigationController?.navigationBar.bounds.height)!), style: .plain)
        let identifer = "cell"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifer)
        view.addSubview(tableView)
        
        /// 设置头部刷新控件
        tableView.mj_header = MJRefreshNormalHeader()
        
        /// 设置尾部刷新控件
        tableView.mj_footer = MJRefreshBackNormalFooter()
        
        /// 初始化ViewModel
        let viewModel = MJRefreshViewModel(input: (headerRefresh: tableView.mj_header.rx.refreshing.asObservable(), footerRefresh: tableView.mj_footer.rx.refreshing.asObservable()), dependency: (disposeBag: disposeBag, networkService: MJRefreshNetworkService()))
        
        /// 单元格数据的绑定
        viewModel.tableData.bind(to: tableView.rx.items) { tableView, row, element in
            let cell = tableView.dequeueReusableCell(withIdentifier: identifer)!
            cell.textLabel?.text = "\(row + 1)、\(element)"
            return cell
        }.disposed(by: disposeBag)
        
        /// 下拉刷新状态结束的绑定
        viewModel.endHeaderRefreshing.bind(to: tableView.mj_header.rx.enRefreshing).disposed(by: disposeBag)
        
        /// 上拉刷新状态结束的绑定
        viewModel.endFooterRefreshing.bind(to: tableView.mj_footer.rx.enRefreshing).disposed(by: disposeBag)
    }
}
