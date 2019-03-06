//
//  UITableViewController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/3/1.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class UITableViewController: BaseController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         UITableView 的基本用法
         1，单个分区的表格
         */
        let tableView = UITableView(frame: view.frame, style: .plain)
        let identifier = "cell"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        view.addSubview(tableView)
        
        let items = Observable.just([
            "文本输入框的用法",
            "开关按钮的用法",
            "进度条的用法",
            "文本标签的用法",
            ])
        
        /// 设置单元格数据（其实就是对 cellForRowAt 的封装）
        items.bind(to: tableView.rx.items) {(tableView, row, element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
            cell.textLabel?.text = "\(row): \(element)"
            return cell
        }.disposed(by: disposeBag)
        
        /**
         2，单元格选中事件响应
         （1）当我们点击某个单元格时将其索引位置，以及对应的标题打印出来。
         （2）如果业务代码直接放在响应方法内部，可以这么写：
         （3）或者也可以在响应中调用外部的方法：
         */
        /// 获取选中项的索引
//        tableView.rx.itemSelected.subscribe(onNext: { (indexPath) in
//            print("选中项的indexPath为：\(indexPath)")
//        }).disposed(by: disposeBag)
        
        /// 获取选中项的内容
//        tableView.rx.modelSelected(String.self).subscribe(onNext: { (item) in
//            print("选中项的标题为：\(item)")
//        }).disposed(by: disposeBag)
        
        /// 获取选中项的索引
//        tableView.rx.itemSelected.subscribe(onNext: {[weak self] (indexPath) in
//            self?.showMessage("选中项的indexPath为：\(indexPath)")
//        }).disposed(by: disposeBag)
        
        /// 获取选中项的内容
        tableView.rx.modelSelected(String.self).subscribe(onNext: {[weak self] (item) in
            self?.showMessage("选中项的标题为：\(item)")
        }).disposed(by: disposeBag)
        
        /**
         3，单元格取消选中事件响应
         */
        /// 获取被取消选中项的索引
//        tableView.rx.itemDeselected.subscribe(onNext: { [weak self] indexPath in
//            self?.showMessage("被取消选中项的indexPath为：\(indexPath)")
//        }).disposed(by: disposeBag)
        
        /// 获取被取消选中项的内容
//        tableView.rx.modelDeselected(String.self).subscribe(onNext: {[weak self] item in
//            self?.showMessage("被取消选中项的的标题为：\(item)")
//        }).disposed(by: disposeBag)
        
        /**
         4，单元格删除事件响应
         */
        /// 获取删除项的索引
        tableView.rx.itemDeleted.subscribe(onNext: { [weak self] indexPath in
            self?.showMessage("删除项的indexPath为：\(indexPath)")
        }).disposed(by: disposeBag)
        
        /// 获取删除项的内容
        tableView.rx.modelDeleted(String.self).subscribe(onNext: {[weak self] item in
            self?.showMessage("删除项的的标题为：\(item)")
        }).disposed(by: disposeBag)
        
        /**
         5，单元格移动事件响应
         */
        /// 获取移动项的索引
        tableView.rx.itemMoved.subscribe(onNext: { [weak self]
            sourceIndexPath, destinationIndexPath in
            self?.showMessage("移动项原来的indexPath为：\(sourceIndexPath)")
            self?.showMessage("移动项现在的indexPath为：\(destinationIndexPath)")
        }).disposed(by: disposeBag)
        
        /**
         6，单元格插入事件响应
         */
        /// 获取插入项的索引
        tableView.rx.itemInserted.subscribe(onNext: { [weak self] indexPath in
            self?.showMessage("插入项的indexPath为：\(indexPath)")
        }).disposed(by: disposeBag)
        
        /**
         7，单元格尾部附件（图标）点击事件响应
         */
        /// 获取点击的尾部图标的索引
        tableView.rx.itemAccessoryButtonTapped.subscribe(onNext: { [weak self] indexPath in
            self?.showMessage("尾部项的indexPath为：\(indexPath)")
        }).disposed(by: disposeBag)
        
        /**
         8，单元格将要显示出来的事件响应
         */
        /// 获取选中项的索引
        tableView.rx.willDisplayCell.subscribe(onNext: { cell, indexPath in
            print("将要显示单元格indexPath为：\(indexPath)")
            print("将要显示单元格cell为：\(cell)\n")
        }).disposed(by: disposeBag)
    }
}

extension UITableViewController {
    fileprivate func showMessage(_ text:String) -> Void {
        let alertController = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        let sureAction = UIAlertAction(title: "确定", style: .default, handler: nil)
        alertController.addAction(sureAction)
        present(alertController, animated: true, completion: nil)
    }
}
