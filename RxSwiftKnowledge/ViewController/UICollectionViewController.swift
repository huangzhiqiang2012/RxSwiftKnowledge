//
//  UICollectionViewController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/3/4.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class MyCollectionViewCell: UICollectionViewCell {
    
    lazy var label:UILabel = {
        let label:UILabel = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.orange
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
}

class UICollectionViewController: BaseController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         单个分区的集合视图
         */
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 100, height: 70)
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(MyCollectionViewCell.self))
        view.addSubview(collectionView)
        
        let items = Observable.just([
            "Swift",
            "PHP",
            "Ruby",
            "Java",
            "C++"
            ])
        items.bind(to: collectionView.rx.items) { (collectionView, row, element) in
            let indexPath = IndexPath(row: row, section: 0)
            let cell:MyCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(MyCollectionViewCell.self), for: indexPath) as! MyCollectionViewCell
            cell.label.text = "\(row): \(element)"
            return cell
        }.disposed(by: disposeBag)
        
        /**
         单元格选中事件响应
         */
        /// 获取选中项的索引
//        collectionView.rx.itemSelected.subscribe(onNext: {[weak self] (indexPath) in
//            self?.showMessage("选中项的indexPath为：\(indexPath)")
//        }).disposed(by: disposeBag)
        
        /// 获取选中项的内容
//        collectionView.rx.modelSelected(String.self).subscribe(onNext: {[weak self] (item) in
//            self?.showMessage("选中项的标题为：\(item)")
//        }).disposed(by: disposeBag)
        
        /// 同时获取选中项的索引，以及内容
//        Observable.zip(collectionView.rx.itemSelected, collectionView.rx.modelSelected(String.self)).bind {[weak self] indexPath, item in
//            self?.showMessage("选中项的indexPath为：\(indexPath) 选中项的标题为：\(item)")
//        }.disposed(by: disposeBag)
        
        /**
         单元格取消选中事件响应
         */
        /// 获取被取消选中项的索引
//        collectionView.rx.itemDeselected.subscribe(onNext: { [weak self] indexPath in
//            self?.showMessage("被取消选中项的indexPath为：\(indexPath)")
//        }).disposed(by: disposeBag)
        
        /// 获取被取消选中项的内容
//        collectionView.rx.modelDeselected(String.self).subscribe(onNext: {[weak self] item in
//            self?.showMessage("被取消选中项的的标题为：\(item)")
//        }).disposed(by: disposeBag)
        
        /// 同时获取被取消选中项的索引，以及内容
//        Observable.zip(collectionView.rx.itemDeselected, collectionView.rx.modelDeselected(String.self)).bind { [weak self] indexPath, item in
//            self?.showMessage("被取消选中项的indexPath为：\(indexPath) 被取消选中项的的标题为：\(item)")
//        }.disposed(by: disposeBag)
        
        /**
         单元格高亮完成后的事件响应
         */
        collectionView.rx.itemHighlighted.subscribe(onNext: { (indexPath) in
            print("高亮单元格的indexPath为：\(indexPath)")
        }).disposed(by: disposeBag)
        
        /**
         单元格转成非高亮完成后的事件响应
         */
        collectionView.rx.itemUnhighlighted.subscribe(onNext: { (indexPath) in
            print("失去高亮单元格的indexPath为：\(indexPath)")
        }).disposed(by: disposeBag)
        
        /**
         单元格将要显示出来的事件响应
         */
        collectionView.rx.willDisplayCell.subscribe(onNext: { (cell, indexPath) in
            print("将要显示单元格indexPath为：\(indexPath) cell为：\(cell)\n")
        }).disposed(by: disposeBag)
        
        /**
         分区头部或尾部将要显示出来的事件响应
         */
        collectionView.rx.willDisplaySupplementaryView.subscribe(onNext: { (view, kind, indexPath) in
            print("将要显示分区indexPath为：\(indexPath) 是头部还是尾部：\(kind) 将要显示头部或尾部视图：\(view)\n")
        }).disposed(by: disposeBag)
        
        /**
         也可以用RxDataSources,用法和tableView差不多,相关的可以查看RxTableViewDataSourcesController.swift
         */
    }
}

extension UICollectionViewController {
    fileprivate func showMessage(_ text:String) -> Void {
        let alertController = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        let sureAction = UIAlertAction(title: "确定", style: .default, handler: nil)
        alertController.addAction(sureAction)
        present(alertController, animated: true, completion: nil)
    }
}
