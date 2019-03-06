//
//  MoyaController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/3/6.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import Moya
import RxCocoa
import RxSwift

/**
 网络请求层
 我们先创建一个 DouBanAPI作为网络请求层，里面的内容如下：
 首先定义一个 provider，即请求发起对象。往后我们如果要发起网络请求就使用这个 provider。
 接着声明一个 enum 来对请求进行明确分类，这里我们定义两个枚举值分别表示获取频道列表、获取歌曲信息。
 最后让这个 enum 实现 TargetType 协议，在这里面定义我们各个请求的 url、参数、header 等信息。
 */

/** 下面定义豆瓣FM请求的endpoints（供provider使用）**/
/// 请求分类
public enum DouBanAPI {
    case channels          /// 获取频道列表
    case playlist(String)  /// 获取歌曲
}

/// 请求配置
extension DouBanAPI : TargetType {
    
    /// 服务器地址
    public var baseURL: URL {
        switch self {
        case .channels:
            return URL(string: "https://www.douban.com")!
        case .playlist(_):
            return URL(string: "https://douban.fm")!
        }
    }
    
    /// 各个请求的具体路径
    public var path: String {
        switch self {
        case .channels:
            return "/j/app/radio/channels"
        case .playlist(_):
            return "/j/mine/playlist"
        }
    }
    
    /// 请求类型
    public var method: Moya.Method {
        return .get
    }
    
    /// 这个就是做单元测试模拟的数据，只会在单元测试文件中有作用
    public var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    /// 请求任务事件（这里附带上参数）
    public var task: Task {
        switch self {
        case .playlist(let channel):
            var params:[String:Any] = [:]
            params["channel"] = channel
            params["type"] = "n"
            params["from"] = "mainsite"
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    /// 请求头
    public var headers: [String : String]? {
        return nil
    }
}

class PlaylistModel: BaseModel {
    var r: Int?
    var isShowQuickStart: Int?
    var song:[SongModel]?
}

class SongModel: BaseModel {
    var title: String?
    var artist: String?
}

class DouBanNetworkService {
    
    let douBanProvider = MoyaProvider<DouBanAPI>()
    
    /// 获取频道数据
    func loadChannels() -> Observable<[ChannelModel]> {
        return douBanProvider.rx.request(.channels).mapJSON().map {
            DoubanModel.deserialize(from: ($0 as! [String : Any]))?.channels ?? []
            }.asObservable()
    }
    
    /// 获取歌曲列表数据
    func loadPlaylist(channelId:String) -> Observable<PlaylistModel> {
        return douBanProvider.rx.request(.playlist(channelId)).mapJSON().map {
            PlaylistModel.deserialize(from: ($0 as! [String : Any])) ?? PlaylistModel()
            }.asObservable()
    }
    
    /// 获取频道下第一首歌曲
    func loadFirstSong(channelId:String) -> Observable<SongModel> {
        return loadPlaylist(channelId: channelId).filter {
            if let song = $0.song {
                return song.count > 0
            }
            return false
            }.map{
                if let song = $0.song {
                    return song[0]
                }
                return SongModel()
        }
    }
}

class MoyaController: BaseController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 初始化豆瓣FM请求的provider
        let douBanProvider = MoyaProvider<DouBanAPI>()
        
        /// 获取数据方式1
        douBanProvider.rx.request(.channels)
            .subscribe { event in
                switch event {
                case let .success(response):
                    
                    /// 数据处理
                    let str = String(data: response.data, encoding: String.Encoding.utf8)
                    print("返回的数据是：", str ?? "")
                case let .error(error):
                    print("数据请求失败!错误原因：", error)
                }
            }.disposed(by: disposeBag)
        
        /// 获取数据方式2
        douBanProvider.rx.request(.channels).subscribe(onSuccess: { (response) in
            
            /// 数据处理
            let str = String(data: response.data, encoding: String.Encoding.utf8)
            print("返回的数据是：", str ?? "")
        }, onError: { (error) in
            print("数据请求失败!错误原因：", error)
        }).disposed(by: disposeBag)
        
        /**
         将结果转为 JSON 对象
         如果服务器返回的数据是 json 格式的话，直接通过 Moya 提供的 mapJSON 方法即可将其转成 JSON 对象。
         */
        douBanProvider.rx.request(.channels).subscribe(onSuccess: { (response) in
            
            /// 数据处理
            let json = try? response.mapJSON() as! [String : Any]
            print("--- 请求成功！返回的如下数据 ---")
            print(json!)
        }, onError: { (error) in
            print("数据请求失败!错误原因：", error)
        }).disposed(by: disposeBag)
        
        douBanProvider.rx.request(.channels).mapJSON().subscribe(onSuccess: { (data) in
            
            /// 数据处理
            let json = data as! [String: Any]
            print("--- 请求成功！返回的如下数据 ---")
            print(json)
        }, onError: { (error) in
            print("数据请求失败!错误原因：", error)
        }).disposed(by: disposeBag)
        
        /**
         将结果映射成自定义对象
         */
        let tableView = UITableView(frame: view.bounds, style: .plain)
        let identifier = "cell"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        view.addSubview(tableView)
        
//        let data = douBanProvider.rx.request(.channels).mapJSON().map {
//            DoubanModel.deserialize(from: ($0 as! [String : Any]))?.channels ?? []
//            }.asObservable()
//        data.bind(to: tableView.rx.items) { (tableView, row, element) in
//            let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
//            cell.textLabel?.text = "\(element.name ?? "")"
//            cell.accessoryType = .disclosureIndicator
//            return cell
//        }.disposed(by: disposeBag)
//
//        tableView.rx.modelSelected(ChannelModel.self).map {$0.channel_id ?? ""}.flatMap{douBanProvider.rx.request(.playlist($0))}.mapJSON().map {
//            PlaylistModel.deserialize(from: ($0 as! [String : Any]))
//            }.subscribe(onNext: {[weak self] (playlist) in
//                if let playlist = playlist {
//                    if let song = playlist.song {
//                        if song.count > 0 {
//                            let artist = song[0].artist
//                            let title = song[0].title
//                            let message = "歌手: \(artist ?? "")\n歌曲: \(title ?? "")"
//                            self?.showAlert(title: "歌曲信息", message: message)
//                        }
//                    }
//                }
//            }).disposed(by: disposeBag)
        
        /**
         将网络请求服务提取出来
         可以把网络请求和数据转换相关代码提取出来，作为一个专门的 Service。比如 DouBanNetworkService
         */
        let networkService = DouBanNetworkService()
        
        let data = networkService.loadChannels()
        data.bind(to: tableView.rx.items) { tableView, row, element in
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
            cell.textLabel?.text = "\(element.name ?? "")"
            cell.accessoryType = .disclosureIndicator
            return cell
        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(ChannelModel.self).map {$0.channel_id ?? ""}.flatMap(networkService.loadFirstSong).subscribe(onNext: {[weak self] (song) in
            let artist = song.artist
            let title = song.title
            let message = "歌手: \(artist ?? "")\n歌曲: \(title ?? "")"
            self?.showAlert(title: "歌曲信息", message: message)
        }).disposed(by: disposeBag)
    }
}

extension MoyaController {
    fileprivate func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .cancel))
        self.present(alert, animated: true)
    }
}
