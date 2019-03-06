//
//  UITableViewDifferentCellController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/3/4.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class titleImageCell: UITableViewCell {
    
    lazy var titleLabel: UILabel = {
        let titleLabel: UILabel = UILabel(frame: CGRect(x: 10, y: 7, width: 100, height: 30))
        return titleLabel
    }()
    
    lazy var iconView: UIImageView = {
        let iconView:UIImageView = UIImageView(frame: CGRect(x: UIScreen.main.bounds.size.width - 10 - 30, y: 7, width: 30, height: 30))
        return iconView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class titleSwitchCell: UITableViewCell {
    
    lazy var titleLabel: UILabel = {
        let titleLabel: UILabel = UILabel(frame: CGRect(x: 10, y: 7, width: 100, height: 30))
        return titleLabel
    }()
    
    lazy var customSwitch: UISwitch = {
        let customSwitch:UISwitch = UISwitch(frame: CGRect(x: UIScreen.main.bounds.size.width - 10 - 51, y: 7, width: 51, height: 30))
        return customSwitch
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(customSwitch)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum SectionItem {
    case TitleImageSectionItem(title:String, image:UIImage)
    
    case TitleSwitchSectionItem(title:String, enabled:Bool)
}

struct MySection1 {
    var header: String
    var items:[SectionItem]
}

extension MySection1 : SectionModelType {
    typealias Item = SectionItem
    
    init(original: MySection1, items: [Item]) {
        self = original
        self.items = items
    }
}

class UITableViewDifferentCellController: BaseController {
    
    var dataSource:RxTableViewSectionedReloadDataSource<MySection1>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         在之前的文章中，同一个 tableView 里的单元格类型都是一样的。但有时我们需要在一个 tableView 里显示多种类型的数据，这就要求 tableView 可以根据当前行的数据自动使用不同类型的 cell。下面通过样例演示这个功能如何实现。
         */
        let tableView = UITableView(frame: view.frame, style: .plain)
        tableView.register(titleImageCell.self, forCellReuseIdentifier: NSStringFromClass(titleImageCell.self))
        tableView.register(titleSwitchCell.self, forCellReuseIdentifier: NSStringFromClass(titleSwitchCell.self))
        
        /// 也可以用delegate实现
//        tableView.rowHeight = 44
        view.addSubview(tableView)
        
        let sections = Observable.just([
            MySection1(header:"我是第一个分区", items:[
                .TitleImageSectionItem(title: "图片数据1", image: UIImage(named: "cart")!),
                .TitleImageSectionItem(title: "图片数据2", image: UIImage(named: "category")!),
                .TitleSwitchSectionItem(title: "开关数据1", enabled: true),
                ]),
            MySection1(header:"我是第二个分区", items:[
                .TitleSwitchSectionItem(title: "开关数据2", enabled: false),
                .TitleSwitchSectionItem(title: "开关数据3", enabled: false),
                .TitleImageSectionItem(title: "图片数据3", image: UIImage(named: "home")!),
                ]),
            ])
        
        let dataSource = RxTableViewSectionedReloadDataSource<MySection1>(configureCell: { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            switch dataSource[indexPath] {
            case let .TitleImageSectionItem(title, image):
                let cell:titleImageCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(titleImageCell.self), for:indexPath) as! titleImageCell
                cell.titleLabel.text = title
                cell.iconView.image = image
                return cell
                
            case let .TitleSwitchSectionItem(title, enabled):
                let cell:titleSwitchCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(titleSwitchCell.self), for:indexPath) as! titleSwitchCell
                cell.titleLabel.text = title
                cell.customSwitch.isOn = enabled
                return cell
            }
        }, titleForHeaderInSection: { (dataSource, index) -> String? in
            return dataSource.sectionModels[index].header
        })
        self.dataSource = dataSource
        
        sections.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
}

extension UITableViewDifferentCellController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let _ = dataSource?[indexPath], let _ = dataSource?[indexPath.section] else {
            return 0.000
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.red
        let titleLabel = UILabel()
        titleLabel.text = self.dataSource?[section].header
        titleLabel.textColor = UIColor.brown
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: view.bounds.size.width / 2, y: 20)
        headerView.addSubview(titleLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}
