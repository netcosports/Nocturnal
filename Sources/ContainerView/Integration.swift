//
//  Integration.swift
//  Nocturnal
//
//  Created by Sergei Mikhan on 8.05.21.
//

import UIKit

import Astrolabe
import Sundial

import RxSwift
import RxCocoa

extension CollectionView: AutoscrollContainer,
                          ViewStateContainer,
                          DisposableContainer,
                          PullToRefreshContainer,
                          Lifecycle {

  public var visibility: Observable<Bool> {
    guard let host = containerView.source.hostViewController else {
      return .empty()
    }
    return host.visibility
  }


  public var pullToRefresh: Observable<Void> {
    guard let refreshControl = containerView.refreshControl else {
      return .empty()
    }
    return refreshControl.rx.controlEvent(.valueChanged).asObservable()
  }
}

public extension CollectionViewContainer where
  Self: AutoscrollContainer &
        ViewStateContainer &
        DisposableContainer &
        PullToRefreshContainer {

  typealias Decoration = EmptyViewCollectionViewLayout.LoaderDecoration
  typealias EmptyViewCell = CollectionViewCell & Reusable & Decorationable

  func integrate<EmptyView: EmptyViewCell, LoaderView: Decoration>(
    emptyViewLayout: EmptyViewCollectionViewLayout,
    emptyView: EmptyView.Type,
    emptyViewData: EmptyView.Data,
    loaderView: LoaderView.Type,
    refreshControl: UIRefreshControl?,
    hostViewController: UIViewController?
  ) where EmptyView.Data: Equatable {

    emptyViewLayout.register(emptyViewDecoration: emptyView,
                             emptyViewData: emptyViewData,
                             showEmptyView: emptyViewSubject)

    emptyViewLayout.register(loaderDecoration: LoaderView.self,
                             showLoaderView: loaderViewSubject)

    subscribeToAutoscrollEvents()

    containerView.collectionViewLayout = emptyViewLayout

    switch emptyViewLayout.scrollDirection {
    case .horizontal:
      containerView.alwaysBounceHorizontal = true
    default:
      containerView.alwaysBounceVertical = true
    }

    containerView.showsVerticalScrollIndicator = false
    containerView.showsHorizontalScrollIndicator = false

    // FIXME: not so sure that we still need this
    containerView.rx.observe(CGRect.self, "bounds")
      .observeOn(MainScheduler.asyncInstance)
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] _ in
        self?.containerView.collectionViewLayout.invalidateLayout()
      })
      .disposed(by: disposeBag)

    if let refreshControl = refreshControl {
      refreshControl.rx
        .controlEvent(.valueChanged)
        .bind(to: pullToRefreshSubject)
        .disposed(by: disposeBag)

      containerView.refreshControl = refreshControl
      loaderViewSubject.filter { !$0 } .bind(to: refreshControl.rx.isRefreshing).disposed(by: disposeBag)
    }

    hostViewController?.view.addSubview(containerView)
    containerView.source.hostViewController = hostViewController
  }
}

