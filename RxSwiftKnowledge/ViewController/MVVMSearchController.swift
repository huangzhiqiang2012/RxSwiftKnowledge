//
//  MVVMSearchController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/3/6.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Moya
import HandyJSON

public enum GitHubSearchAPI {
    case repositories(String)
}

extension GitHubSearchAPI : TargetType {
    public var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
    
    public var path: String {
        switch self {
        case .repositories:
            return "/search/repositories"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    public var task: Task {
        print("发起请求。")
        switch self {
        case .repositories(let query):
            var params: [String: Any] = [:]
            params["q"] = query
            params["sort"] = "stars"
            params["order"] = "desc"
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        return nil

    }
}

class GitHubRepositoriesModel : BaseModel {
    var total_count: Int?
    var incomplete_results: Bool?
    var items: [GitHubRepositoryModel]?
}

class GitHubRepositoryModel: BaseModel {
    var id: Int?
    var name: String?
    var full_name:String?
    var html_url:String?
    var description:String?
}

class GitHubSearchService {
    func searchRepositories(query:String) -> Driver<GitHubRepositoriesModel> {
        
        /// 不能在这里初始化,需要在执行方法前就得初始化,
        /// let gitHubProvider = MoyaProvider<GitHubAPI>()
        return gitHubProvider.rx.request(.repositories(query)).filterSuccessfulStatusCodes().mapJSON().map {
            GitHubRepositoriesModel.deserialize(from: ($0 as! [String : Any])) ?? GitHubRepositoriesModel()
            }.asDriver(onErrorDriveWith:Driver.empty())
    }
    
    fileprivate var  gitHubProvider : MoyaProvider<GitHubSearchAPI>
    
    init() {
        gitHubProvider = MoyaProvider<GitHubSearchAPI>()
    }
}

class ViewModel {
    
    /**** 输入部分 ***/
    /// 查询行为
    fileprivate let searchAction:Driver<String>
    
    /**** 输出部分 ***/
    /// 所有的查询结果
    let searchRsult:Driver<GitHubRepositoriesModel>
    
    /// 查询结果里的资源列表
    let repositories:Driver<[GitHubRepositoryModel]>
    
    /// 清空结果动作
    let cleanResult:Driver<Void>
    
    /// 导航栏标题
    let navigationTitle:Driver<String>
    
    /// ViewModel初始化（根据输入实现对应的输出）
    init(searchAction:Driver<String>) {

        let networkService = GitHubSearchService()
        
        self.searchAction = searchAction
        
        /// 生成查询结果序列
        self.searchRsult = searchAction.filter{!$0.isEmpty}.flatMapLatest(networkService.searchRepositories)
        
        /// 生成清空结果动作序列
        self.cleanResult = searchAction.filter{$0.isEmpty}.map { _ in Void()}
        
        /// 生成查询结果里的资源列表序列（如果查询到结果则返回结果，如果是清空数据则返回空数组）
        self.repositories = Driver.merge(searchRsult.map {
            if let items = $0.items {
                return items
            }
            return []
        }, cleanResult.map {[]})
        
        /// 生成导航栏标题序列（如果查询到结果则返回数量，如果是清空数据则返回默认标题）
        self.navigationTitle = Driver.merge(searchRsult.map {
            if let count = $0.total_count {
               return "共有 \(count) 个结果"
            }
            return "共有 0 个结果"
        }, cleanResult.map{"www.github.com"})
    }
}

class MVVMSearchController: BaseController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         MVC 架构
         
         1，基本介绍
         （1）MVC 是 Model-View-Controller 的缩写。它主要有如下三层结构：
         Model：数据层。负责读写数据，保存App 状态等。
         View：界面显示层。负责和用户交互，向用户显示页面，反馈用户行为等。
         Controller：业务逻辑层。负责业务逻辑、事件响应、数据加工等工作。
         （2）通常情况下，Model 与 View 之间是不允许直接通信的，而必须由 Controller 层进行协调。
         
         2，优点
         使用 MVC 架构可以帮助我们很好地将数据、页面、逻辑的代码分离开来，使得每一层相对独立。同时我们还能够将一些通用的功能抽离出来，实现代码复用。
         
         3，缺点
         虽然 MVC 架构久经考验，但它并不是十分适合 iOS 项目的开发。因为在 iOS 项目中：
         ViewController 既扮演了View的角色，又扮演了 Controller 的角色。
         而 Model 在 ViewController 中又可以直接与 View 进行交互。
         一旦 App 的交互复杂些，就会发现 ViewController 将变得十分臃肿。大量代码被添加到控制器中，使得控制器负担过重。同时 View 与 Controller 混在一起，也不容易实现 View 层的复用。
         */
        
        /**
         MVVM 架构
         
         1，基本介绍
         （1）MVVM 是 Model-View-ViewModel 的缩写。MVVM 可以说是是 MVC 模式的升级版：
         MVVM 增加了 ViewModel 层。我们可以将原来 Controller 中的业务逻辑抽取出来放到 ViewModel 中，从而大大减轻了 ViewController 的负担。
         同时在 MVVM 中，ViewController 只担任 View 的角色（ViewController 与 View 现在共同作为 View 层），负责 View 的显示和更新，其他业务逻辑不再需要 ViewController 来管了。
         （2）同样使用 MVVM 架构时，Model 与 View|ViewControllter 之间是不允许直接通信的，而是由 ViewModel 层进行协调。
         
         2，优点
         通过将原本在 ViewController 的视图显示逻辑、验证逻辑、网络请求等代码存放于 ViewModel 中：
         一来可以对 ViewController 进行瘦身。
         二来可以实现视图逻辑的复用。比如一个 ViewModel 可以绑定到不同的 View 上，让多个 view 重用相同的视图逻辑。
         而且使用 MVVM 可以大大降低代码的耦合性，不仅方便测试、维护，也方便多人协作开发。
         
         3，缺点
         （1）相较于 MVC，使用 MVVM 会轻微的增加代码量。但总体上减少了代码的复杂性，个人觉得还是值得的。
         （2）还有就是学习成本。使用 MVVM 还是有许多地方要学习的。比如 View 与 ViewModel 之间的数据绑定，如果驾驭不好，同样会造成代码逻辑复杂，不易维护的问题。
         */
        
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 56))
        let tableView = UITableView(frame: view.bounds, style: .plain)
        let identifier = "cell"
        
        /// 不用注册,不然注册的cell,style是默认的,无法显示detailTextLabel,设置也不会显示
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.tableHeaderView = searchBar
        view.addSubview(tableView)
        
        /// 查询条件输入
        let searchAction = searchBar.rx.text.orEmpty.asDriver().throttle(0.5) /// 只有间隔超过0.5k秒才发送
        .distinctUntilChanged()
        
        /// 初始化ViewModel
        let viewModel = ViewModel(searchAction:searchAction)
        
        /// 绑定导航栏标题数据
        viewModel.navigationTitle.drive(self.navigationItem.rx.title).disposed(by: disposeBag)
        
        /// 将数据绑定到表格
        viewModel.repositories.drive(tableView.rx.items) { tableView, row, element in
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
            if cell == nil {
                
                /// subtitle设置detailTextLabel才有效
                cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: identifier)
            }
            cell!.textLabel?.text = element.name
            cell!.detailTextLabel?.text = element.html_url
            return cell!
        }.disposed(by: disposeBag)
        
        /// 单元格点击
        tableView.rx.modelSelected(GitHubRepositoryModel.self).subscribe(onNext: {[weak self] (item) in
            self?.showAlert(title: item.full_name, message: item.description)
        }).disposed(by: disposeBag)
    }
}

extension MVVMSearchController {
    fileprivate func showAlert(title:String?, message:String?){
        let alertController = UIAlertController(title: title,
                                                message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
