//
//  ViewController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/2/28.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: BaseController {
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate lazy var datas : Observable<[String]> = {
        let datas : Observable<[String]> = Observable.just(["Observable",
                                                            "Observer",
                                                            "SubjectsAndVariables",
                                                            "TransformingObservables",
                                                            "FilteringObservables",
                                                            "ConditionalAndBooleanOperators",
                                                            "CombiningObservables",
                                                            "MathematicalAndAggregateOperators",
                                                            "ConnectableObservableOperators",
                                                            "ObservableUtilityOperators",
                                                            "ErrorHandlingOperators",
                                                            "DebugOperation",
                                                            "SingleCompletableMaybe",
                                                            "Driver",
                                                            "Schedulers",
                                                            "UILabel",
                                                            "UITextFieldUITextView",
                                                            "UIButtonUIBarButtonItem",
                                                            "UISegmentedControl",
                                                            "UIActivityIndicatorViewUIApplication",
                                                            "UISliderUIStepper",
                                                            "TwoWayBinding",
                                                            "UIGestureRecognizer",
                                                            "UIDatePicker",
                                                            "UITableView",
                                                            "RxTableViewDataSources",
                                                            "UITableViewEdit",
                                                            "UITableViewDifferentCell",
                                                            "UICollectionView",
                                                            "UIPickerView",
                                                            "WeakSelfUnownedSelf",
                                                            "URLSession",
                                                            "RxAlamofire",
                                                            "Moya",
                                                            "MVVMSearch",
                                                            "MVVMRegister",
                                                            "MJRefresh",
                                                            "DelegateProxyLocation",
                                                            "DelegateProxyUIImagePicker",
                                                            "DelegateProxyUIApplication",
                                                            "SendMessageAndMethodInvoked",
                                                            "UITableViewCellButtonClick",
                                                            "NotificationCenter",
                                                            "KVO",
                                                            ])
        return datas
    }()
    
    fileprivate let cellIdentifier = "cellIdentifier";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "RxSwiftKnowledge"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        datas.bind(to:tableView.rx.items(cellIdentifier:cellIdentifier, cellType:UITableViewCell.self)) { _, title, cell in
            cell.textLabel?.text = title
        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(String.self).subscribe(onNext: {[weak self] str in
            if let self = self {
                let vcStr = str + "Controller"
                if let vc = vcStr.getVCController() {
                    vc.title = str
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }).disposed(by: disposeBag)
    }
}

extension String {
    func getVCController() -> UIViewController? {
        guard let nameSpace = Bundle.main.infoDictionary!["CFBundleExecutable"] as? String else {
            print("没有命名空间")
            return nil
        }
        guard let childVCClass = NSClassFromString(nameSpace + "." + self) else {
            print("没有获取到对应的class")
            return nil
        }
        guard let childVCType = childVCClass as? UIViewController.Type else {
            print("没有得到的类型")
            return nil
        }
        let vc = childVCType.init()
        return vc
    }
}

