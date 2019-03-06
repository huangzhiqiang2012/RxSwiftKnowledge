//
//  URLSessionController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/3/5.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import HandyJSON

class BaseModel: HandyJSON {
    required init() {}
}

class DoubanModel: BaseModel {
    var channels:[ChannelModel]?
}

class ChannelModel: BaseModel {
    var name: String?
    var name_en:String?
    var channel_id: String?
    var seq_id: Int?
    var abbr_en: String?
}

class URLSessionController: BaseController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         RxSwift（或者说 RxCocoa）除了对系统原生的 UI 控件提供了 rx 扩展外，对 URLSession 也进行了扩展，从而让我们可以很方便地发送 HTTP 请求。
         */
        /**
         通过 rx.response 请求数据
         */
        let urlStr = "https://www.douban.com/j/app/radio/channels"
        let url = URL(string: urlStr)
        let request = URLRequest(url: url!)
        URLSession.shared.rx.response(request: request).subscribe(onNext: { (response: HTTPURLResponse, data: Data) in
            let str = String(data: data, encoding: String.Encoding.utf8)
            print("--__--|| 返回的数据是: \(str ?? "")")
        }).disposed(by: disposeBag)
        
        /**
         从上面样例可以发现，不管请求成功与否都会进入到 onNext 这个回调中。如果我们需要根据响应状态进行一些相应操作，比如：
         状态码在 200 ~ 300 则正常显示数据。
         如果是异常状态码（比如：404）则弹出告警提示框。
         这个借助 response 参数进行判断即可。
         */
        URLSession.shared.rx.response(request: URLRequest(url: URL(string:"https://www.douban.com/xxxxxxx/app/radio/channels")!)).subscribe(onNext: { (response: HTTPURLResponse, data: Data) in
            if 200 ..< 300 ~= response.statusCode {
                let str = String(data: data, encoding: String.Encoding.utf8)
                print("--__--|| 返回的数据是: \(str ?? "")")
            } else {
                print("--__--|| 请求失败")
            }
        }).disposed(by: disposeBag)
        
        /**
         通过 rx.data 请求数据
         rx.data 与 rx.response 的区别：
         如果不需要获取底层的 response，只需知道请求是否成功，以及成功时返回的结果，那么建议使用 rx.data。
         因为 rx.data 会自动对响应状态码进行判断，只有成功的响应（状态码为 200~300）才会进入到 onNext 这个回调，否则进入 onError 这个回调。
         */
        URLSession.shared.rx.data(request: request).subscribe(onNext: { (data) in
            let str = String(data: data, encoding: String.Encoding.utf8)
            print("--__--|| 返回的数据是: \(str ?? "")")
        }, onError: { error in
            print("请求失败！错误原因：", error)
        }).disposed(by: disposeBag)
        
        /**
         在很多情况下，网络请求并不是由程序自动发起的。可能需要我们点击个按钮，或者切换个标签时才去请求数据。除了手动发起请求外，同样的可能还需要手动取消上一次的网络请求（如果未完成）。下面通过样例演示这个如何实现。
         */
        let sendRequestButton = UIButton(type: .custom)
        sendRequestButton.frame = CGRect(x: 50, y: 100, width: 100, height: 30)
        sendRequestButton.setTitle("发起请求", for: .normal)
        sendRequestButton.setTitleColor(UIColor.blue, for: .normal)
        view.addSubview(sendRequestButton)
        
        let cancleRequestButton = UIButton(type: .custom)
        cancleRequestButton.frame = CGRect(x: sendRequestButton.frame.maxX + 50, y: sendRequestButton.frame.origin.y, width: sendRequestButton.bounds.size.width, height: sendRequestButton.bounds.size.height)
        cancleRequestButton.setTitle("取消请求", for: .normal)
        cancleRequestButton.setTitleColor(UIColor.blue, for: .normal)
        view.addSubview(cancleRequestButton)
        
        sendRequestButton.rx.tap.asObservable().flatMap {
            URLSession.shared.rx.data(request: request).takeUntil(cancleRequestButton.rx.tap)
        }.subscribe(onNext: { (data) in
            let str = String(data: data, encoding: String.Encoding.utf8)
            print("--__--|| 请求成功! 返回的数据是: \(str ?? "")")
        }, onError: { (error) in
            print("请求失败！错误原因：", error)
        }).disposed(by: disposeBag)
        
        /**
         将结果转为 JSON 对象
         如果服务器返回的数据是 json 格式的话，我们可以使用iOS 内置的 JSONSerialization 将其转成 JSON 对象，方便我们使用。
         */
        URLSession.shared.rx.data(request: request).subscribe(onNext: { (data) in
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any]
            print("--__--|| 请求成功!返回如下数据:")
            print(json!)
        }).disposed(by: disposeBag)
        
        /**
         当然我们在订阅前就进行转换也是可以的：
         */
        URLSession.shared.rx.data(request: request).map {
            try? JSONSerialization.jsonObject(with: $0, options: .allowFragments) as! [String : Any]
        }.subscribe(onNext: { (data) in
            print("--__--|| 请求成功!返回如下数据:")
            print(data!)
        }).disposed(by: disposeBag)
        
        /**
         还有更简单的方法，就是直接使用 RxSwift 提供的 rx.json 方法去获取数据，它会直接将结果转成 JSON 对象。
         */
        URLSession.shared.rx.json(request: request).subscribe(onNext: { (data) in
            let json = data as! [String : Any]
            print("--__--|| 请求成功!返回如下数据:")
            print(json)
        }).disposed(by: disposeBag)
        
        /**
         将结果映射成自定义对象
         */
        let tableView = UITableView(frame: view.bounds, style: .plain)
        view.addSubview(tableView)
        let identifier = "cell"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        let datasArr = URLSession.shared.rx.json(request: request).map {
            DoubanModel.deserialize(from: ($0 as! [String : Any]))
        }.map {$0!.channels ?? []}
        
        datasArr.bind(to: tableView.rx.items) { tableView, row, element in
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
            cell.textLabel?.text = "\(row): \(element.name!)"
            return cell
        }.disposed(by: disposeBag)
    }
}
