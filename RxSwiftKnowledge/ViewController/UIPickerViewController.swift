//
//  UIPickerViewController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/3/5.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class UIPickerViewController: BaseController {
    
    let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 100))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(pickerView)
        
         /// 最简单的pickerView适配器（显示普通文本）
//        let stringPickerAdapter = RxPickerViewStringAdapter<[[String]]>(
//            components: [],
//            numberOfComponents: { dataSource,pickerView,components  in components.count },
//            numberOfRowsInComponent: { (_, _, components, component) -> Int in
//                return components[component].count },
//            titleForRow: { (_, _, components, row, component) -> String? in
//                return components[component][row]}
//        )
        
        /// 绑定pickerView数据
//        Observable.just([["One", "Two", "Three"],
//                         ["A", "B", "C", "D"]]).bind(to: pickerView.rx.items(adapter: stringPickerAdapter)).disposed(by: disposeBag)
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: (view.bounds.size.width - 100) * 0.5, y: pickerView.frame.maxY + 50, width: 100, height: 30)
        button.backgroundColor = UIColor.blue
        button.setTitle("获取信息", for: .normal)
        button.rx.tap.bind {[weak self] in
            self?.getPickerViewValue()
        }.disposed(by: disposeBag)
        view.addSubview(button)
        
        /**
         修改默认的样式
         我们将选项的文字修改成橙色，同时在文字下方加上双下划线。
         */
//        let attrStringPickerAdapter = RxPickerViewAttributedStringAdapter<[[String]]>(
//            components: [],
//            numberOfComponents: { dataSource,pickerView,components  in components.count },
//            numberOfRowsInComponent: { (_, _, components, component) -> Int in
//                return components[component].count },
//            attributedTitleForRow: { (_, _, components, row, component) -> NSAttributedString? in
//                return NSAttributedString(string: components[component][row], attributes: [NSAttributedString.Key.foregroundColor:UIColor.orange, NSAttributedString.Key.underlineStyle:NSUnderlineStyle.double.rawValue, NSAttributedString.Key.textEffect:NSAttributedString.TextEffectStyle.letterpressStyle])
//        })
//
//        Observable.just([["One", "Two", "Three"],
//                         ["A", "B", "C", "D"]]).bind(to: pickerView.rx.items(adapter: attrStringPickerAdapter)).disposed(by: disposeBag)
        
        /**
         使用自定义视图
         */
        let viewPickerAdaper = RxPickerViewViewAdapter<[UIColor]>(components: [], numberOfComponents: { (_, _, _) -> Int in
            1
        }, numberOfRowsInComponent: { (_, _, items, _) -> Int in
            return items.count
        }) { (_, _, items, row, _, view) -> UIView in
            let componentView = view ?? UIView()
            componentView.backgroundColor = items[row]
            return componentView
        }
        Observable.just([UIColor.red, UIColor.orange, UIColor.yellow]).bind(to: pickerView.rx.items(adapter: viewPickerAdaper)).disposed(by: disposeBag)
    }
}

extension UIPickerViewController {
    @objc fileprivate func getPickerViewValue() {
        let message = String(pickerView.selectedRow(inComponent: 0)) + "-" + String(pickerView.selectedRow(inComponent: 1))
        let alertController = UIAlertController(title: "被选中的索引为", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
