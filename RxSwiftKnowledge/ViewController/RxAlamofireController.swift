//
//  RxAlamofireController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/3/6.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Alamofire
import RxAlamofire

class RxAlamofireController: BaseController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlStr = "https://www.douban.com/j/app/radio/channels"
        let url = URL(string:urlStr)!
        
        /**
         方式1 request
         */
        request(.get, url).data().subscribe(onNext: { (data) in
            let str = String(data: data, encoding: String.Encoding.utf8)
            print("--__--|| 返回的数据是：", str ?? "")
        }, onError: { (error) in
            print("--__--|| 请求失败！错误原因：", error)
        }).disposed(by: disposeBag)
        
        /**
         如果请求的数据是字符串类型的，我们可以在 request 请求时直接通过 responseString()方法实现自动转换，省的在回调中还要手动将 data 转为 string。
         */
        request(.get, url).responseString().subscribe(onNext: { (response, data) in
            print("--__--|| 返回的数据是：", data)
        }, onError: { (error) in
            print("--__--|| 请求失败！错误原因：", error)
        }).disposed(by: disposeBag)
        
        /**
         当然更简单的方法就是直接使用 requestString 去获取数据
         */
        requestString(.get, url).subscribe(onNext: { (response, data) in
            print("--__--|| 返回的数据是：", data)
        }, onError: { (error) in
            print("--__--|| 请求失败！错误原因：", error)
        }).disposed(by: disposeBag)
        
        /**
         方式2 requestData 不管请求成功与否都会进入到 onNext 这个回调中。如果我们想要根据响应状态进行一些相应操作，通过 response 参数即可实现
         */
        requestData(.get, url).subscribe(onNext: { (response, data) in
            if 200 ..< 300 ~= response.statusCode {
                let str = String(data: data, encoding: String.Encoding.utf8)
                print("--__--|| 请求成功! 返回的数据是：", str ?? "")
            } else {
                print("--__--|| 请求失败!")
            }
        }).disposed(by: disposeBag)
        
        /**
         将结果转为 JSON 对象
         */
        /**
         方式1 使用 iOS 内置的 JSONSerialization
         */
        request(.get, url).data().subscribe(onNext: { (data) in
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any]
            print("--- 请求成功！返回的如下数据 ---")
            print(json!)
        }).disposed(by: disposeBag)
        
        /**
         方式2 在订阅前使用 responseJSON() 进行转换
         */
        request(.get, url).responseJSON().subscribe(onNext: { (dataResponse) in
            let json = dataResponse.value as! [String : Any]
            print("--- 请求成功！返回的如下数据 ---")
            print(json)
        }).disposed(by: disposeBag)
        
        /**
         方式3 直接使用 requestJSON 方法去获取 JSON 数据
         */
        requestJSON(.get, url).subscribe(onNext: { (response, data) in
            let json = data as! [String : Any]
            print("--- 请求成功！返回的如下数据 ---")
            print(json)
        }).disposed(by: disposeBag)
        
        /**
         将结果映射成自定义对象
         */
        let tableView = UITableView(frame: view.bounds, style: .plain)
        view.addSubview(tableView)
        let identifier = "cell"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        let datasArr = requestJSON(.get, url).map {
            DoubanModel.deserialize(from: ($1 as! [String : Any]))
        }.map {$0!.channels ?? []}
        
        datasArr.bind(to: tableView.rx.items) { tableView, row, element in
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
            cell.textLabel?.text = "\(row): \(element.name!)"
            return cell
            }.disposed(by: disposeBag)
        
        /**
         文件上传
         支持如下上传类型 File Data Stream MultipartFormData
         */
        let fileURL = Bundle.main.url(forResource: "test", withExtension: "zip") ?? URL(string: "www.baidu.com")
        let uploadURL = URL(string: "http://www.baidu.com/upload.php")!
        upload(fileURL!, urlRequest: try! urlRequest(.post, uploadURL)).subscribe(onNext: { element in
            print("--- 开始上传 ---")
            element.uploadProgress(closure: { (progress) in
                print("当前进度：\(progress.fractionCompleted)")
                print("  已上传载：\(progress.completedUnitCount/1024)KB")
                print("  总大小：\(progress.totalUnitCount/1024)KB")
            })
        }, onError: { error in
            print("上传失败! 失败原因：\(error)")
        }, onCompleted: {
            print("上传完毕!")
        }).disposed(by: disposeBag)
        
        /**
         将进度转成可观察序列
         */
        let progressView = UIProgressView(frame: CGRect(x: 20, y: 100, width: view.bounds.size.width - 40, height: 30))
        view.addSubview(progressView)
        upload(fileURL!, urlRequest: try! urlRequest(.post, uploadURL)).map { request in
            Observable<Float>.create({ observer in
                request.uploadProgress(closure: { (progress) in
                    observer.onNext(Float(progress.fractionCompleted))
                    if progress.isFinished {
                        observer.onCompleted()
                    }
                })
                return Disposables.create()
            })
        }.flatMap {$0}.bind(to: progressView.rx.progress).disposed(by: disposeBag)
        
        /**
         上传 MultipartFormData 类型的文件数据（类似于网页上 Form 表单里的文件提交）
         文本参数与文件一起提交（文件除了可以使用 fileURL，还可以上传 Data 类型的文件数据）
         */
        let strData = "www.baidu.com".data(using: String.Encoding.utf8) ?? Data()
        let intData = String(10).data(using: String.Encoding.utf8) ?? Data()
        let fileURL1 = Bundle.main.url(forResource: "0", withExtension: "png") ?? URL(string: "www.baidu.com")
        let fileURL2 = Bundle.main.url(forResource: "1", withExtension: "png") ?? URL(string: "www.baidu.com")
        upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(strData, withName: "value1")
            multipartFormData.append(intData, withName: "value2")
            multipartFormData.append(fileURL1!, withName: "file1")
            multipartFormData.append(fileURL2!, withName: "file2")
        }, to: uploadURL, encodingCompletion: { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON(completionHandler: { (response) in
                    debugPrint(response)
                })
            case .failure(let encodingError):
                print(encodingError)
            }
        })
        
        /**
         文件下载
         */
        /// 指定下载路径（文件名不变）
        let destination: DownloadRequest.DownloadFileDestination = {_, response in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(response.suggestedFilename!)
            
            /// 两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        let fileURL3 = URL(string: "www.baidu.com")!
        download(URLRequest(url: fileURL3), to: destination).subscribe(onNext: { (element) in
            print("开始下载")
            element.downloadProgress(closure: { (progress) in
                print("当前进度: \(progress.fractionCompleted)")
                print("  已下载：\(progress.completedUnitCount/1024)KB")
                print("  总大小：\(progress.totalUnitCount/1024)KB")
            })
        }, onError: { (error) in
            print("下载失败! 失败原因：\(error)")
        }, onCompleted: {
            print("下载完毕!")
        }).disposed(by: disposeBag)
        
        /**
         使用默认提供的下载路径
         Alamofire 内置的许多常用的下载路径方便我们使用，简化代码。注意的是，使用这种方式如果下载路径下有同名文件，不会覆盖原来的文件。
         */
        /// 下载到用户文档目录下可以改成：
        let destination1 = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
    }
}
