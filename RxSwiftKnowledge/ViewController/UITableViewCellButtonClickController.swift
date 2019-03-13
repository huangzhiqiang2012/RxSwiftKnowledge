//
//  UITableViewCellButtonClickController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/3/12.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class UITableViewCellButtonClickTableViewCell: UITableViewCell {
    
    var button:UIButton!
    
    var disposeBag = DisposeBag()
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 25)
        button.setTitle("点击", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.backgroundColor = UIColor.orange
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        contentView.addSubview(button)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.center = CGPoint(x: bounds.size.width - 35, y: bounds.midY)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class UITableViewCellButtonClickController: BaseController {
    
    var tableView:UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         我们知道通过订阅 tableView 的 itemSelected 或 modelSelected 这两个 Rx 扩展方法，可以对单元格的点击事件进行响应，并执行相关的业务代码。
         但有时我们并不需要整个 cell 都能进行点击响应，可能是点击单元格内的按钮时才触发相关的操作，下面通过样例演示这个功能的实现。
         */
        
        tableView = UITableView(frame: view.frame, style: .plain)
        let identifier = "cell"
        tableView.register(UITableViewCellButtonClickTableViewCell.self, forCellReuseIdentifier: identifier)
        
        /// 单元格无法选中
        tableView.allowsSelection = false
        view.addSubview(tableView)
        
        let items = Observable.just([
            "文本输入框的用法",
            "开关按钮的用法",
            "进度条的用法",
            "文本标签的用法",
            ])
        
        items.bind(to: tableView.rx.items) { tableView, row, element in
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! UITableViewCellButtonClickTableViewCell
            cell.textLabel?.text = element
            cell.button.rx.tap.asDriver().drive(onNext: { [weak self] in
                self?.showAlert(title: "\(row)", message: element)
            }).disposed(by: cell.disposeBag)
            return cell
        }.disposed(by: disposeBag)
    }
}

extension UITableViewCellButtonClickController {
    fileprivate func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .cancel))
        self.present(alert, animated: true)
    }
}
