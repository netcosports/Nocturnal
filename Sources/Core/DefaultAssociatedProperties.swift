//
//  DefaultAssociatedProperties.swift
//  CoreUI
//
//  Created by Sergei Mikhan on 2/14/20.
//

import Foundation
import UIKit
import Astrolabe
import Sundial
import RxSwift
import RxCocoa

private enum Associated {
  static var autoscrollObserver = "autoscrollObserver"
  static var disposeBag = "disposeBag"
  static var pullToRefreshSubject = "pullToRefreshSubject"
  static var autoScrollSubject = "autoScrollSubject"
  static var emptyViewSubject = "emptyViewSubject"
  static var errorSubject = "errorSubject"
  static var loaderViewSubject = "loaderViewSubject"
  static var refreshViewSubject = "refreshViewSubject"
  static var bindDisposeBag = "bindDisposeBag"
  static var isHostApplingTransparency = "isHostApplingTransparency"
  static var currentNavigationBarTransparency = "currentNavigationBarTransparency"
}

public extension DisposableContainer {

  var disposeBag: DisposeBag {
    if let disposeBag = objc_getAssociatedObject(self, &Associated.disposeBag)
                     as? DisposeBag {
        return disposeBag
    }
    let disposeBag = DisposeBag()
    objc_setAssociatedObject(self,
                             &Associated.disposeBag,
                             disposeBag,
                             .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return disposeBag
  }
}

public extension PullToRefreshContainer {

  var pullToRefreshSubject: PublishSubject<Void> {
    if let subject = objc_getAssociatedObject(self, &Associated.pullToRefreshSubject)
                     as? PublishSubject<Void> {
        return subject
    }
    let subject = PublishSubject<Void>()
    objc_setAssociatedObject(self,
                             &Associated.pullToRefreshSubject,
                             subject,
                             .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return subject
  }
}

public extension AutoscrollContainer {

  var autoScrollSubject: PublishSubject<AutoScrollTarget> {
    if let subject = objc_getAssociatedObject(self, &Associated.autoScrollSubject)
                     as? PublishSubject<AutoScrollTarget> {
        return subject
    }
    let subject = PublishSubject<AutoScrollTarget>()
    objc_setAssociatedObject(self,
                             &Associated.autoScrollSubject,
                             subject,
                             .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return subject
  }
}

public extension ViewStateContainer {

  var errorSubject: BehaviorSubject<Error?> {
    if let subject = objc_getAssociatedObject(self, &Associated.errorSubject)
                     as? BehaviorSubject<Error?> {
        return subject
    }
    let subject = BehaviorSubject<Error?>(value: nil)
    objc_setAssociatedObject(self,
                             &Associated.errorSubject,
                             subject,
                             .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return subject
  }

  var emptyViewSubject: BehaviorSubject<Bool> {
    if let subject = objc_getAssociatedObject(self, &Associated.emptyViewSubject)
                     as? BehaviorSubject<Bool> {
        return subject
    }
    let subject = BehaviorSubject<Bool>(value: false)
    objc_setAssociatedObject(self,
                             &Associated.emptyViewSubject,
                             subject,
                             .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return subject
  }

  var loaderViewSubject: BehaviorSubject<Bool> {
    if let subject = objc_getAssociatedObject(self, &Associated.loaderViewSubject)
                     as? BehaviorSubject<Bool> {
        return subject
    }
    let subject = BehaviorSubject<Bool>(value: false)
    objc_setAssociatedObject(self,
                             &Associated.loaderViewSubject,
                             subject,
                             .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return subject
  }

  var refreshViewSubject: BehaviorSubject<Bool> {
    if let subject = objc_getAssociatedObject(self, &Associated.refreshViewSubject)
                     as? BehaviorSubject<Bool> {
        return subject
    }
    let subject = BehaviorSubject<Bool>(value: false)
    objc_setAssociatedObject(self,
                             &Associated.refreshViewSubject,
                             subject,
                             .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return subject
  }
}

extension NavigationBarTransparency {

  public var isHostApplingTransparency: Bool {
    set {
      objc_setAssociatedObject(self,
                             &Associated.isHostApplingTransparency,
                             newValue,
                             .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    get {
      return objc_getAssociatedObject(self, &Associated.isHostApplingTransparency) as? Bool ?? false
    }
  }

  public var currentNavigationBarTransparency: BehaviorSubject<CGFloat> {
    if let subject = objc_getAssociatedObject(self, &Associated.currentNavigationBarTransparency)
                     as? BehaviorSubject<CGFloat> {
        return subject
    }
    let subject = BehaviorSubject<CGFloat>(value: 0.0)
    objc_setAssociatedObject(self,
                             &Associated.currentNavigationBarTransparency,
                             subject,
                             .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return subject
  }
}
