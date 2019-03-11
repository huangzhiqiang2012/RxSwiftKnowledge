//
//  DelegateProxyLocationController.swift
//  RxSwiftKnowledge
//
//  Created by Darren on 2019/3/8.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import CoreLocation

func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    return returnValue
}

func castOptionalOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T? {
    if NSNull().isEqual(object) {
        return nil
    }
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    return returnValue
}

extension CLLocationManager : HasDelegate {
    public typealias Delegate = CLLocationManagerDelegate
}

extension Reactive where Base: CLLocationManager {
    
    public var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base)
    }
    
    public var didUpdateLocations: Observable<[CLLocation]> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base).didUpdateLocationsSubject.asObservable()
    }
    
    public var didFailWithError: Observable<Error> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base).didFailWithErrorSubject.asObservable()
    }
    
    #if os(iOS) || os(macOS)
    public var didFinishDeferredUpdatesWithError: Observable<Error?> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didFinishDeferredUpdatesWithError:))).map({ a in
            return try castOptionalOrThrow(Error.self, a[1])
        })
    }
    #endif
    
    #if os(iOS)
    public var didPauseLocationUpdates: Observable<Void> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManagerDidPauseLocationUpdates(_:))).map { _ in
            return ()
        }
    }
    
    public var didResumeLocationUpdates: Observable<Void> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManagerDidResumeLocationUpdates(_:))).map { _ in
            return ()
        }
    }
    
    public var didUpdateHeading: Observable<CLHeading> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateHeading:))).map { a in
            return try castOrThrow(CLHeading.self, a[1])
        }
    }
    
    public var didEnterRegion: Observable<CLRegion> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didEnterRegion:))).map { a in
            return try castOrThrow(CLRegion.self, a[1])
        }
    }
    
    public var didExitRegion: Observable<CLRegion> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didExitRegion:))).map { a in
            return try castOrThrow(CLRegion.self, a[1])
        }
    }
    #endif
    
    #if os(iOS) || os(macOS)
    @available(OSX 10.10, *)
    public var didDetermineStateForRegion: Observable<(state: CLRegionState, region: CLRegion)> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didDetermineState:for:))).map { a in
            let stateNumber = try castOrThrow(NSNumber.self, a[1])
            let state = CLRegionState(rawValue: stateNumber.intValue) ?? CLRegionState.unknown
            let region = try castOrThrow(CLRegion.self, a[2])
            return (state: state, region: region)
        }
    }
    
    public var monitoringDidFailForRegionWithError: Observable<(region: CLRegion?, error: Error)> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:monitoringDidFailFor:withError:))).map { a in
            let region = try castOptionalOrThrow(CLRegion.self, a[1])
            let error = try castOrThrow(Error.self, a[2])
            return (region: region, error: error)
        }
    }
    
    public var didStartMonitoringForRegion: Observable<CLRegion> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didStartMonitoringFor:))).map { a in
            return try castOrThrow(CLRegion.self, a[1])
        }
    }
    #endif
    
    #if os(iOS)
    public var didRangeBeaconsInRegion: Observable<(beacons: [CLBeacon], region: CLBeaconRegion)> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didRangeBeacons:in:))).map { a in
            let beacons = try castOrThrow([CLBeacon].self, a[1])
            let region = try castOrThrow(CLBeaconRegion.self, a[2])
            return (beacons: beacons, region:region)
        }
    }
    
    public var rangingBeaconsDidFailForRegionWithError: Observable<(region: CLBeaconRegion, error: Error)> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:rangingBeaconsDidFailFor:withError:))).map { a in
            let region = try castOrThrow(CLBeaconRegion.self, a[1])
            let error = try castOrThrow(Error.self, a[2])
            return (region: region, error: error)
        }
    }
    
    @available(iOS 8.0, *)
    public var didVisit: Observable<CLVisit> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didVisit:))).map { a in
            return try castOrThrow(CLVisit.self, a[1])
        }
    }
    #endif
    
    public var didChangeAuthorizationStatus: Observable<CLAuthorizationStatus> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didChangeAuthorization:))).map { a in
            let number = try castOrThrow(NSNumber.self, a[1])
            return CLAuthorizationStatus(rawValue: Int32(number.intValue)) ?? .notDetermined
        }
    }
}

public class RxCLLocationManagerDelegateProxy: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, DelegateProxyType , CLLocationManagerDelegate {
    
    public init(locationManager: CLLocationManager) {
        super.init(parentObject: locationManager, delegateProxy: RxCLLocationManagerDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxCLLocationManagerDelegateProxy(locationManager: $0)}
    }
    
    internal lazy var didUpdateLocationsSubject = PublishSubject<[CLLocation]>()
    
    internal lazy var didFailWithErrorSubject = PublishSubject<Error>()
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        _forwardToDelegate?.locationManager(manager, didUpdateLocations: locations)
        didUpdateLocationsSubject.onNext(locations)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        _forwardToDelegate?.locationManager(manager, didFailWithError: error)
        didFailWithErrorSubject.onNext(error)
    }
    
    deinit {
        didUpdateLocationsSubject.onCompleted()
        didFailWithErrorSubject.onCompleted()
    }
}

/// 地理定位服务层
class GeolocationService {
    
    /// 单例模式
    static let `default` = GeolocationService()
    
    /// 定位权限序列
    private (set) var authorized: Driver<Bool>
    
    /// 经纬度信息序列
    private (set) var location: Driver<CLLocationCoordinate2D>
    
    /// 定位管理器
    private let locationManager = CLLocationManager()
    
    init() {
        
        /// 更新距离
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        /// 设置定位精度
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        /// 获取定位权限序列
        authorized = Observable.deferred { [weak locationManager] in
            let status = CLLocationManager.authorizationStatus()
            guard let locationManager = locationManager else {
                return Observable.just(status)
            }
            return locationManager.rx.didChangeAuthorizationStatus.startWith(status)
            }.asDriver(onErrorJustReturn: CLAuthorizationStatus.notDetermined).map {
                switch $0 {
                case .authorizedAlways:
                    return true
                default:
                    return false
                }
            }
        
        /// 获取经纬度信息序列
        location = locationManager.rx.didUpdateLocations.asDriver(onErrorJustReturn: []).flatMap {
            return $0.last.map(Driver.just) ?? Driver.empty()
            }.map{ $0.coordinate }
        
        /// 发送授权申请
        locationManager.requestAlwaysAuthorization()
        
        /// 允许使用定位服务的话，开启定位服务更新
        locationManager.startUpdatingLocation()
    }
}

class DelegateProxyLocationController: BaseController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
         委托（delegate） iOS 开发中十分常见。不管是使用系统自带的库，还是一些第三方组件时，我们总能看到 delegate 的身影。使用 delegate 可以实现代码的松耦合，减少代码复杂度。但如果我们项目中使用 RxSwift，那么原先的 delegate 方式与我们链式编程方式就不相称了。
                 解决办法就是将代理方法进行一层 Rx 封装，这样做不仅会减少许多不必要的工作（比如原先需要遵守不同的代理，并且要实现相应的代理方法），还会使得代码的聚合度更高，更加符合响应式编程的规范。
                 其实在 RxCocoa 源码中我们也可以发现，它已经对标准的 Cocoa 做了大量的封装（比如 tableView 的 itemSelected）。下面我将通过样例演示如何将代理方法进行 Rx 化。
         */
        
        /**
         一、对 Delegate进行Rx封装原理
         DelegateProxy
         （1）DelegateProxy 是代理委托，我们可以将它看作是代理的代理。
         （2）DelegateProxy 的作用是做为一个中间代理，他会先把系统的 delegate 对象保存一份，然后拦截 delegate 的方法。也就是说在每次触发 delegate 方法之前，会先调用 DelegateProxy 这边对应的方法，我们可以在这里发射序列给多个订阅者。以 UIScrollView 为例，Delegate proxy 便是其代理委托，它遵守 DelegateProxyType 与 UIScrollViewDelegate，并能响应 UIScrollViewDelegate 的代理方法，这里我们可以为代理委托设计它所要响应的方法（即为订阅者发送观察序列）。
         */
        
        /**
         二、要获取定位信息，首先我们需要在 info.plist 里加入相关的定位描述：
         Privacy - Location Always and When In Use Usage Description：我们需要通过您的地理位置信息获取您周边的相关数据
         Privacy - Location When In Use Usage Description：我们需要通过您的地理位置信息获取您周边的相关数据
         */
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 20, y: 100, width: view.bounds.size.width - 40, height: 30)
        button.backgroundColor = UIColor.blue
        button.setTitle("定位服务未开启,点击开启", for: .normal)
        view.addSubview(button)
        
        let label = UILabel(frame: CGRect(x: button.frame.origin.x, y: button.frame.maxY + 50, width: button.bounds.size.width, height: button.bounds.size.height * 2))
        label.numberOfLines = 0
        label.textAlignment = .center
        view.addSubview(label)
        
        /// 获取地理定位服务
        let geolocationService = GeolocationService.default
        
        /// 定位权限绑定到按钮上(是否可见)
        geolocationService.authorized.drive(button.rx.isHidden).disposed(by: disposeBag)
        
        /// 经纬度信息绑定到label上显示
        geolocationService.location.drive(label.rx.coordinates).disposed(by: disposeBag)
        
        /// 按钮点击
        button.rx.tap.bind { [weak self] in
            self?.openAppPreferences()
        }.disposed(by: disposeBag)
    }
}

extension DelegateProxyLocationController {
    fileprivate func openAppPreferences() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
}

/// UILabel的Rx扩展
extension Reactive where Base: UILabel {
    
    /// 实现CLLocationCoordinate2D经纬度信息的绑定显示
    var coordinates: Binder<CLLocationCoordinate2D> {
        return Binder(base) { label, location in
            label.text = "经度: \(location.longitude)\n 纬度: \(location.latitude)"
        }
    }
}
