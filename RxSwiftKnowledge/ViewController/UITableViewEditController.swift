//
//  UITableViewEditController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/3/4.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

/// 定义各种操作命令
enum TableEditingCommand {
    case setItems(items: [String])                   ///< 设置表格数据
    case addItem(item: String)                       ///< 新增数据
    case moveItem(from: IndexPath, to: IndexPath)    ///< 移动数据
    case deleteItem(IndexPath)                       ///< 删除数据
}

/// 定义表格对应的ViewModel
struct TableViewModel {
    
    /// 表格数据项
    fileprivate var items:[String]
    
    init(items: [String] = []) {
        self.items = items
    }
    
    /// 执行相应的命令，并返回最终的结果
    func execute(command: TableEditingCommand) -> TableViewModel {
        switch command {
        case .setItems(let items):
            print("设置表格数据")
            return TableViewModel(items: items)
            
        case .addItem(let item):
            print("新增数据项")
            var items = self.items
            items.append(item)
            return TableViewModel(items: items)
            
        case .moveItem(let from, let to):
            print("移动数据项")
            var items = self.items
            items.insert(items.remove(at: from.row), at: to.row)
            return TableViewModel(items: items)
            
        case .deleteItem(let indexPath):
            print("删除数据项")
            var items = self.items
            items.remove(at: indexPath.row)
            return TableViewModel(items: items)
        }
    }
}

class UITableViewEditController: BaseController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         可编辑表格
         1，效果图
         （1）程序启动后表格会自动加载 5 条随机数据。点击“刷新”按钮则又重新生成 5 条数据并显示。
         （2）点击“加号”图标后，会在当前数据集的末尾添加一条随机数据并显示。
         （3）点击单元格左侧的“减号”图标则可以将该行数据删除。
         （4）拖动单元格右侧的控制图标可以改变显示顺序。
         */
        
        let tableView = UITableView(frame: view.frame, style: .plain)
        let identifier = "cell"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        view.addSubview(tableView)
        
        let refreshButton = UIBarButtonItem(title: "刷新", style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = refreshButton
        
        let addButton = UIBarButtonItem(title: "+", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = addButton
        
        /// 表格模型
        let initialVM = TableViewModel()
        
        /// 刷新数据命令
        let refreshCommand = refreshButton.rx.tap.asObservable()
        .startWith(()) /// 加这个为了页面初始化时会自动加载一次数据
        .flatMapLatest(getRandomResult)
        .map(TableEditingCommand.setItems)
        
        /// 新增条目命令
        let addCommand = addButton.rx.tap.asObservable().map {"\(arc4random())"}.map(TableEditingCommand.addItem)
        
        /// 移动位置命令
        let movedCommand = tableView.rx.itemMoved.map(TableEditingCommand.moveItem)
        
        /// 删除条目命令
        let deleteCommand = tableView.rx.itemDeleted.map(TableEditingCommand.deleteItem)
        
        let dataSource:RxTableViewSectionedAnimatedDataSource
            <AnimatableSectionModel<String, String>> = RxTableViewSectionedAnimatedDataSource(animationConfiguration: AnimationConfiguration(insertAnimation: .top, reloadAnimation: .fade, deleteAnimation: .left),
            configureCell: { (dataSource, tv, indexPath, element) -> UITableViewCell in
                let cell = tv.dequeueReusableCell(withIdentifier: identifier)!
                cell.textLabel?.text = "条目\(indexPath.row)：\(element)"
                return cell
        }, canEditRowAtIndexPath: { (_, _) -> Bool in
            return true
        }, canMoveRowAtIndexPath: { (_, _) -> Bool in
            return true
        })
        
        /// 绑定单元格数据
        Observable.of(refreshCommand, addCommand, movedCommand, deleteCommand).merge().scan(initialVM) { (vm: TableViewModel, command: TableEditingCommand) -> TableViewModel in
            return vm.execute(command: command)
        }
        .startWith(initialVM)
        .map {
            [AnimatableSectionModel(model: "", items: $0.items)]
        }
        .share(replay: 1)
        .bind(to: tableView.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
        
        tableView.setEditing(true, animated: true)
    }
}

extension UITableViewEditController {
    fileprivate func getRandomResult() -> Observable<[String]> {
        print("生成随机数据")
        let items = (0 ..< 5).map { _ in
            "\(arc4random())"
        }
        return Observable.just(items)
    }
}
