//
//  DelegateProxyUIImagePickerController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/3/11.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/// 图片选择控制器（UIImagePickerController）代理委托
class RxImagePickerDelegateProxy: DelegateProxy<UIImagePickerController,  UIImagePickerControllerDelegate & UINavigationControllerDelegate>, DelegateProxyType, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    init(imagePicker: UIImagePickerController) {
        super.init(parentObject: imagePicker, delegateProxy: RxImagePickerDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register {
            RxImagePickerDelegateProxy(imagePicker: $0)
        }
    }
    
    static func currentDelegate(for object: UIImagePickerController) -> (UIImagePickerControllerDelegate & UINavigationControllerDelegate)? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?, to object: UIImagePickerController) {
        object.delegate = delegate
    }
}

/// 取消指定视图控制器函数
func dismissViewController(_ viewController: UIViewController, animated: Bool) {
    if viewController.isBeingDismissed || viewController.isBeingPresented {
        DispatchQueue.main.async {
            dismissViewController(viewController, animated: animated)
        }
        return
    }
    if viewController.presentingViewController != nil {
        viewController.dismiss(animated: animated, completion: nil)
    }
}

/// 图片选择控制器（UIImagePickerController）的Rx扩展
extension Reactive where Base: UIImagePickerController {
    
    /// 用于创建并自动显示图片选择控制器的静态方法
    /// 后面当我们使用该方法初始化 ImagePickerController 时会自动将其弹出显示，并且在选择完毕后会自动关闭
    static func createWithParent(_ parent: UIViewController?, animated: Bool = true, configureImagePicker:@escaping(UIImagePickerController) throws -> () = { x in }) -> Observable<UIImagePickerController> {
        
        /// 返回可观察序列
        return Observable.create { [weak parent] observer in
            
            /// 初始化一个图片选择控制器
            let imagePicker = UIImagePickerController()
            
            /// 不管图片选择完毕还是取消选择，都会发出.completed事件
            let dismissDisposable = Observable.merge(
                imagePicker.rx.didFinishPickingMediaWithInfo.map { _ in ()},
                imagePicker.rx.didCancel
                ).subscribe(onNext: { _ in
                    observer.onCompleted()
                })
            
            do {
                try configureImagePicker(imagePicker)
            }
            catch let error {
                observer.onError(error)
                return Disposables.create()
            }
            
            /// 判断parent是否存在，不存在则发出.completed事件
            guard let parent = parent else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            /// 弹出控制器，显示界面
            parent.present(imagePicker, animated: animated, completion: nil)
            
            /// 发出.next事件（携带的是控制器对象）
            observer.onNext(imagePicker)
            
            /// 销毁时自动退出图片控制器
            return Disposables.create(dismissDisposable, Disposables.create {
                dismissViewController(imagePicker, animated: animated)
                })
            }
    }
    
    /// 代理委托
    public var pickerDelegate: DelegateProxy<UIImagePickerController,  UIImagePickerControllerDelegate & UINavigationControllerDelegate> {
        return RxImagePickerDelegateProxy.proxy(for: base)
    }
    
    /// 图片选择完毕代理方法的封装
    public var didFinishPickingMediaWithInfo: Observable<[UIImagePickerController.InfoKey : AnyObject]> {
        return pickerDelegate.methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:))).map { a in
            return try castOrThrow(Dictionary<UIImagePickerController.InfoKey, AnyObject>.self, a[1])
        }
    }
    
    /// 图片取消选择代理方法的封装
    public var didCancel: Observable<()> {
        return pickerDelegate.methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerControllerDidCancel(_:))).map {_ in ()}
    }
}

class DelegateProxyUIImagePickerController: BaseController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cameraButton = getButton(frame: CGRect(x: 20, y: 30, width: 50, height: 30), title: "拍照")
        view.addSubview(cameraButton)
        
        let galleryButton = getButton(frame: CGRect(x: cameraButton.frame.maxX + 30, y: cameraButton.frame.origin.y, width: 80, height: cameraButton.bounds.size.height), title: "选择照片")
        view.addSubview(galleryButton)
        
        let cropButton = getButton(frame: CGRect(x: galleryButton.frame.maxX + 30, y: cameraButton.frame.origin.y, width: 120, height: cameraButton.bounds.size.height), title: "选择照片并裁剪")
        view.addSubview(cropButton)
        
        let width = view.bounds.size.width - cameraButton.frame.origin.x * 2
        let imageView = UIImageView(frame: CGRect(x: cameraButton.frame.origin.x, y: cameraButton.frame.maxY + 20, width: width, height: width))
        view.addSubview(imageView)
        
        /// 判断并决定"拍照"按钮是否可用
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        /// “拍照”按钮点击
        cameraButton.rx.tap
        .flatMapLatest { [weak self] _ in
            return UIImagePickerController.rx.createWithParent(self) { picker in
                picker.sourceType = .camera
                picker.allowsEditing = false
            }
            .flatMap { $0.rx.didFinishPickingMediaWithInfo }
        }
        .map { info in
            return info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        .bind(to: imageView.rx.image)
        .disposed(by: disposeBag)
        
        /// “选择照片”按钮点击
        galleryButton.rx.tap.flatMapLatest { [weak self] _ in
            return UIImagePickerController.rx.createWithParent(self) { picker in
                picker.sourceType = .photoLibrary
                picker.allowsEditing = false
                }
                .flatMap { $0.rx.didFinishPickingMediaWithInfo}
        }
        .map { info in
            return info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        .bind(to:imageView.rx.image)
        .disposed(by: disposeBag)
        
        /// “选择照片并裁剪”按钮点击
        cropButton.rx.tap.flatMapLatest { [weak self] _ in
            return UIImagePickerController.rx.createWithParent(self) { picker in
                picker.sourceType = .photoLibrary
                picker.allowsEditing = true
                }
                .flatMap { $0.rx.didFinishPickingMediaWithInfo}
        }
        .map { info in
            return info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        }
        .bind(to: imageView.rx.image)
        .disposed(by: disposeBag)
    }
}

extension DelegateProxyUIImagePickerController {
    fileprivate func getButton(frame:CGRect, title:String) -> UIButton {
        let button = UIButton(type: .custom)
        button.frame = frame
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return button
    }
}
