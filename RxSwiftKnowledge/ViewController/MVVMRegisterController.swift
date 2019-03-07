//
//  MVVMRegisterController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/3/7.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/// GitHub网络请求服务
class GitHubRegisterNetworkService {
    
    /// 验证用户是否存在
    func usernameAvailable(_ username:String) -> Observable<Bool> {
        
        /// 通过检查这个用户的GitHub主页是否存在来判断用户是否存在
        let url = URL(string: "https://github.com/\(username.URLEscaped)")!
        let request = URLRequest(url: url)
        return URLSession.shared.rx.response(request: request).map { pair in
            
            /// 如果不存在该用户主页，则说明这个用户名可用
            return pair.response.statusCode == 404
        }.catchErrorJustReturn(false)
    }
    
    /// 注册用户
    func register(_ username: String, password: String) -> Observable<Bool> {
        
        /// 这里我们没有真正去发起请求，而是模拟这个操作（平均每3次有1次失败）
        let signupResult = arc4random() % 3 == 0 ? false : true
        return Observable.just(signupResult).delay(1, scheduler: MainScheduler.instance)
    }
}

/// 验证结果和信息的枚举
enum ValidationResult {
    case validating                ///< 验证中
    case empty                     ///< 输入为空
    case ok(message:String)        ///< 验证通过
    case failed(message:String)    ///< 验证失败
}

/// 扩展ValidationResult，对应不同的验证结果返回验证是成功还是失败
extension ValidationResult {
    var isValid:Bool {
        switch self {
        case .ok:
            return true
            
        default:
            return false
        }
    }
}

/// 扩展ValidationResult，对应不同的验证结果返回不同的文字描述
extension ValidationResult:CustomStringConvertible {
    var description:String {
        switch self {
        case .validating:
            return "正在验证..."
            
        case .empty:
            return ""
            
        case let .ok(message):
            return message
            
        case let .failed(message):
            return message
        }
    }
}

/// 扩展ValidationResult，对应不同的验证结果返回不同的文字颜色
extension ValidationResult {
    var textColor:UIColor {
        switch self {
        case .validating:
            return UIColor.gray
            
        case .empty:
            return UIColor.black
            
        case .ok:
            return UIColor(red: 0/255, green: 130/255, blue: 0/255, alpha: 1)
            
        case .failed:
            return UIColor.red
        }
    }
}

/// 用户注册服务
class GitHubRegisterService {
    
    /// 密码最少位数
    let minPasswordCount = 5
    
    lazy var networkService = {
        return GitHubRegisterNetworkService()
    }()
    
    /// 验证用户名
    func validateUsername(_ username:String) -> Observable<ValidationResult> {
        
        /// 判断用户名是否为空
        if username.isEmpty {
            return .just(.empty)
        }
        
        /// 判断用户名是否只有数字和字母
        if username.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
            return .just(.failed(message: "用户名只能包含数字和字母"))
        }
        
        /// 发起网络请求检查用户名是否已存在
        return networkService.usernameAvailable(username).map { available in
            
            /// 根据查询情况返回不同的验证结果
            if available {
                return .ok(message: "用户名可用")
            } else {
                return .failed(message: "用户名已存在")
            }
        }.startWith(.validating) /// 在发起网络请求前，先返回一个“正在检查”的验证结果
    }
    
    /// 验证密码
    func validatePassword(_ password:String) -> ValidationResult {
        let numberOfCharacters = password.count
        
        /// 判断密码是否为空
        if numberOfCharacters == 0 {
            return .empty
        }
        
        /// 判断密码位数
        if numberOfCharacters < minPasswordCount {
            return .failed(message: "密码至少需要\(minPasswordCount)个字符")
        }
        
        return .ok(message: "密码有效")
    }
    
    /// 验证二次输入的密码
    func validateRepeatedPassword(_ password:String, repeatedPassword:String) -> ValidationResult {
        
        /// 判断密码是否为空
        if repeatedPassword.count == 0 {
            return .empty
        }
        
        /// 判断两次输入的密码是否一致
        if repeatedPassword == password {
            return .ok(message:"密码有效")
        } else {
            return .failed(message: "两次输入的密码不一致")
        }
    }
}

class GitHubRegisterViewModel {
    
    /// 用户名验证结果
    let validatedUsername: Driver<ValidationResult>
    
    /// 密码验证结果
    let validatedPassword: Driver<ValidationResult>
    
    /// 再次输入密码验证结果
    let validatedPasswordRepeated: Driver<ValidationResult>
    
    /// 注册按钮是否可用
    let registerEnabled: Driver<Bool>
    
    /// 正在注册中
    let resgisting: Driver<Bool>
    
    /// 注册结果
    let registerResult: Driver<Bool>
    
    /// ViewModel初始化（根据输入实现对应的输出）
    init(
        input:(
        username: Driver<String>,
        password: Driver<String>,
        repeatedPassword: Driver<String>,
        loginTaps:Signal<Void>
        ),
        dependency:(
        networkService: GitHubRegisterNetworkService,
        registerService:GitHubRegisterService
        )) {
        
        /// 用户名验证
        validatedUsername = input.username.flatMap { username in
            return dependency.registerService.validateUsername(username).asDriver(onErrorJustReturn: .failed(message: "服务器发生错误!"))
        }
        
        /// 用户名密码验证
        validatedPassword = input.password.map { password in
            return dependency.registerService.validatePassword(password)
        }
        
        /// 重复输入密码验证
        validatedPasswordRepeated = Driver.combineLatest(input.password, input.repeatedPassword, resultSelector: dependency.registerService.validateRepeatedPassword)
        
        /// 注册按钮是否可用
        registerEnabled = Driver.combineLatest(
        validatedUsername,
        validatedPassword,
        validatedPasswordRepeated
        ) { username, password, repeatPassword in
            username.isValid && password.isValid && repeatPassword.isValid
        }.distinctUntilChanged()
        
        /// 获取最新的用户名和密码
        let usernameAndPassword = Driver.combineLatest(input.username, input.password) {
            (username: $0, password: $1)
        }
        
        /// 用于检测是否正在请求数据
        let activityIndicator = ActivityIndicator()
        resgisting = activityIndicator.asDriver()
        
        /// 注册按钮点击结果
        registerResult = input.loginTaps.withLatestFrom(usernameAndPassword).flatMapLatest({ pair in
            return dependency.networkService.register(pair.username, password: pair.password).trackActivity(activityIndicator) /// 把当前序列放入resgisting序列中进行检测
                .asDriver(onErrorJustReturn: false)
        })
    }
}

class MVVMRegisterController: BaseController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nameTextField = getTextField(frame: CGRect(x: 20, y: 30, width: view.bounds.size.width - 40, height: 30), placeholder: "用户名")
        let nameLabel = getLabel(frame: CGRect(x: nameTextField.frame.origin.x, y: nameTextField.frame.maxY, width: nameTextField.bounds.size.width, height: nameTextField.bounds.size.height))
        
        let passwordTextField = getTextField(frame: CGRect(x: nameTextField.frame.origin.x, y: nameLabel.frame.maxY, width: nameTextField.bounds.size.width, height: nameTextField.bounds.size.height), placeholder: "密码")
        let passwordLabel = getLabel(frame: CGRect(x: nameTextField.frame.origin.x, y: passwordTextField.frame.maxY, width: nameTextField.bounds.size.width, height: nameTextField.bounds.size.height))
        
        let repeatedPasswordTextField = getTextField(frame: CGRect(x: nameTextField.frame.origin.x, y: passwordLabel.frame.maxY, width: nameTextField.bounds.size.width, height: nameTextField.bounds.size.height), placeholder: "再次输入密码")
        let repeatedPasswordLabel = getLabel(frame: CGRect(x: nameTextField.frame.origin.x, y: repeatedPasswordTextField.frame.maxY, width: nameTextField.bounds.size.width, height: nameTextField.bounds.size.height))
        
        let registButton = UIButton(type: .custom)
        registButton.frame = CGRect(x: nameTextField.frame.origin.x, y: repeatedPasswordLabel.frame.maxY, width: nameTextField.bounds.size.width, height: nameTextField.bounds.size.height)
        registButton.setTitle("注册", for: .normal)
        registButton.setBackgroundImage(UIImage.createImage(color: UIColor.blue), for: .normal)
        registButton.setBackgroundImage(UIImage.createImage(color: UIColor.blue.withAlphaComponent(0.3)), for: .disabled)
        view.addSubview(registButton)
        
        let viewModel = GitHubRegisterViewModel(
            input: (username: nameTextField.rx.text.orEmpty.asDriver(), password: passwordTextField.rx.text.orEmpty.asDriver(), repeatedPassword: repeatedPasswordTextField.rx.text.orEmpty.asDriver(), loginTaps: registButton.rx.tap.asSignal()),
            dependency: (networkService: GitHubRegisterNetworkService(), registerService: GitHubRegisterService())
        )
        
        /// 用户名验证结果绑定
        viewModel.validatedUsername.drive(nameLabel.rx.validationResult).disposed(by: disposeBag)
        
        /// 密码验证结果绑定
        viewModel.validatedPassword.drive(passwordLabel.rx.validationResult).disposed(by: disposeBag)
        
        /// 再次输入密码验证结果绑定
        viewModel.validatedPasswordRepeated.drive(repeatedPasswordLabel.rx.validationResult).disposed(by: disposeBag)
        
        /// 注册按钮是否可用
        viewModel.registerEnabled.drive(onNext: { (valid) in
            registButton.isEnabled = valid
        }).disposed(by: disposeBag)
        
        /// 当前是否正在注册
        viewModel.resgisting.drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible).disposed(by: disposeBag)
        
        /// 注册结果绑定
        viewModel.registerResult.drive(onNext: {[weak self] (result) in
            self?.showMessage("注册" + (result ? "成功" : "失败") + "!")
        }).disposed(by: disposeBag)
    }
}

extension MVVMRegisterController {
    fileprivate func getTextField(frame:CGRect, placeholder:String) -> UITextField {
        let textField = UITextField(frame: frame)
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        textField.placeholder = placeholder
        textField.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(textField)
        return textField
    }
    
    fileprivate func getLabel(frame:CGRect) -> UILabel {
        let label = UILabel(frame: frame)
        label.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(label)
        return label
    }
    
    fileprivate func showMessage(_ text:String) -> Void {
        let alertController = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        let sureAction = UIAlertAction(title: "确定", style: .default, handler: nil)
        alertController.addAction(sureAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension UIImage {
    class func createImage(color:UIColor) -> UIImage {
        let rect:CGRect = CGRect(x:0.0, y:0.0, width:1.0, height:1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor);
        context.fill(rect);
        var image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        image = image.withRenderingMode(.alwaysOriginal)
        return image
    }
}

extension String {
    var URLEscaped: String {
        
        /// 字符串的url地址转义
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}

extension Reactive where Base: UILabel {
    
    /// 让验证结果（ValidationResult类型）可以绑定到label上
    var validationResult:Binder<ValidationResult> {
        return Binder(base) { label, result in
            label.textColor = result.textColor
            label.text = result.description
        }
    }
}
