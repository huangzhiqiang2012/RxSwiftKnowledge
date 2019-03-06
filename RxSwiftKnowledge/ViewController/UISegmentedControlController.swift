//
//  UISegmentedControlController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/2/28.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class UISegmentedControlController: BaseController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let segmented = UISegmentedControl(items: ["First", "Second", "Third"])
        segmented.frame = CGRect(x: (view.bounds.size.width - 180) * 0.5, y: 100, width: 180, height: 30)
        segmented.selectedSegmentIndex = 0
        view.addSubview(segmented)
        
        let imageView = UIImageView(frame: CGRect(x: (view.bounds.size.width - 100) * 0.5, y: segmented.frame.maxY + 50, width: 100, height: 100))
        view.addSubview(imageView)
        let images = ["cart", "category", "home"]
        
        /// 创建一个当前需要显示的图片的可观察序列
        let showImageObservable:Observable<UIImage> = segmented.rx.selectedSegmentIndex.asObservable().map {
            return UIImage(named: images[$0])!
        }
        
        /// 把需要显示的图片绑定到 imageView 上
        showImageObservable.bind(to: imageView.rx.image).disposed(by: disposeBag)
    }
}
