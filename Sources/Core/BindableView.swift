//
//  BindableView.swift
//  CoreUI
//
//  Created by Sergei Mikhan on 12/28/19.
//

import Astrolabe
import Sundial

import RxSwift
import RxCocoa

public protocol DisposableContainer: AnyObject {

  var disposeBag: DisposeBag { get }
}

public protocol PullToRefreshContainer {

  var pullToRefreshSubject: PublishSubject<Void> { get }
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

public protocol SourceContainer {

  var source: EventDrivenLoaderSource { get }
}

public protocol Lifecycle {

  var visibility: Observable<Bool> { get }
}

public protocol BindableDisposeBagContainer: AnyObject {

  var bindDisposeBag: DisposeBag? { get set }
}

public protocol Bindable {

  init()

  associatedtype ViewModel
  func bind(viewModel: ViewModel)
}

public protocol DisposableBindable: Bindable & BindableDisposeBagContainer {

  func bind(viewModel: ViewModel, with bindDisposeBag: DisposeBag)
}

extension DisposableBindable {

  public func bind(viewModel: ViewModel) {
    let bindDisposeBag = DisposeBag()
    bind(viewModel: viewModel, with: bindDisposeBag)
    self.bindDisposeBag = bindDisposeBag
  }
}

public typealias BindableView = SourceContainer & AutoscrollContainer & ViewStateContainer &
  PullToRefreshContainer & DisposableBindable & Lifecycle & DisposableContainer
