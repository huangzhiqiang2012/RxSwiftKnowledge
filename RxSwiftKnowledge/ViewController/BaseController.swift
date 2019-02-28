//
//  BaseController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/2/28.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class BaseController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    deinit {
        print("--__--|| \(NSStringFromClass(self.classForCoder)) dealloc")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
    }
}
