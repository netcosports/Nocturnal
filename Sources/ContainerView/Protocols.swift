//
//  BindableView.swift
//  Nocturnal
//
//  Created by Sergei Mikhan on 12/28/19.
//

import Astrolabe
import Sundial

import RxSwift
import RxCocoa

public protocol DisposableContainer: class {

  var disposeBag: DisposeBag { get }
}

public protocol PullToRefreshContainer {

  var pullToRefresh: Observable<Void> { get }
}

public protocol ViewStateContainer {

  var errorSubject: BehaviorSubject<Error?> { get }
  var emptyViewSubject: BehaviorSubject<Bool> { get }
  var loaderViewSubject: BehaviorSubject<Bool> { get }
  var refreshViewSubject: BehaviorSubject<Bool> { get }
}

public protocol AutoscrollContainer {

  var autoScrollSubject: PublishSubject<AutoScrollTarget> { get }
}

public protocol Lifecycle {

  var visibility: Observable<Bool> { get }
}
