//
//  CollectionViewContainer.swift
//  CoreUI
//
//  Created by Sergei Mikhan on 12/28/19.
//

import Astrolabe
import Sundial

import RxSwift
import RxCocoa

public protocol CollectionViewContainer {
  associatedtype Source: ReusableSource where Source.Container == UICollectionView

  var containerView: CollectionView<EventDrivenLoaderDecoratorSource<Source>> { get }
  func setupContainerView(with refreshControl: UIRefreshControl?)
}

public extension SourceContainer where Self: CollectionViewContainer {

  var source: EventDrivenLoaderSource {
    return containerView.source
  }
}

public extension CollapsingItem where Self: CollectionViewContainer & Lifecycle {

  var scrollView: UIScrollView {
    return containerView
  }
}

// FIXME: move it into Astrolabe
public extension ReusableSource {

  func indexPath(for cellId: String) -> IndexPath? {
    var indexPath: IndexPath?
    sections.enumerated().forEach { sectionAndIndex in
      sectionAndIndex.element.cells.enumerated().forEach { itemIndex, cell in
        if cell.id == cellId {
          indexPath = IndexPath(item: itemIndex, section: sectionAndIndex.offset)
        }
      }
    }
    return indexPath
  }
}

public extension CollectionViewContainer where
  Self: AutoscrollContainer &
        ViewStateContainer &
        DisposableContainer &
        PullToRefreshContainer {

  typealias Decoration = EmptyViewCollectionViewLayout.LoaderDecoration
  typealias EmptyViewCell = CollectionViewCell & Reusable & Decorationable
  func setup<EmptyView: EmptyViewCell, LoaderView: Decoration>(emptyViewLayout: EmptyViewCollectionViewLayout,
                                                               emptyView: EmptyView.Type,
                                                               emptyViewData: EmptyView.Data,
                                                               loaderView: LoaderView.Type)
    where EmptyView.Data: Equatable {

    emptyViewLayout.register(emptyViewDecoration: emptyView,
                             emptyViewData: emptyViewData,
                             showEmptyView: emptyViewSubject)

    emptyViewLayout.register(loaderDecoration: LoaderView.self,
                             showLoaderView: loaderViewSubject)

    let autoScrollObservable = autoScrollSubject.asObservable().observeOn(MainScheduler.instance)
    autoScrollObservable.flatMap { [weak self, weak emptyViewLayout] target -> Observable<Void> in
      guard let self = self else { return .empty() }
      let index: IndexPath
      switch target.target {
      case .cellId(let cellId):
        guard let indexPathForItem = self.containerView.source.indexPath(for: cellId) else {
          assertionFailure("Can not find cell with id '\(cellId)'")
          return .empty()
        }
        index = indexPathForItem
      case .indexPath(let indexPath):
        index = indexPath
      }
      guard let emptyViewLayout = emptyViewLayout else { return .empty() }
      let sections = self.containerView.source.sections
      if index.section < sections.count && index.item < sections[index.section].cells.count {
        self.containerView.scroll(to: target)
        return .empty()
      }
      return emptyViewLayout.readyObservable
        .filter { [weak self] _ in
          guard let self = self else { return false }
          let sections = self.containerView.source.sections
          return index.section < sections.count && index.item < sections[index.section].cells.count
        }
        .map { _ in () }
        .take(1)
        .do(onNext: { [weak self] in
          guard let self = self else { return }
          self.containerView.scroll(to: target)
        })
    }.subscribe()
    .disposed(by: disposeBag)
    containerView.collectionViewLayout = emptyViewLayout
    switch emptyViewLayout.scrollDirection {
    case .horizontal:
      containerView.alwaysBounceHorizontal = true
    default:
      containerView.alwaysBounceVertical = true
    }
  }
}

public extension Lifecycle where Self: UIViewController {

  var visibility: Observable<Bool> {
    let visible = self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:))).map { _ in return true}
    let invisible = self.rx.sentMessage(#selector(UIViewController.viewDidDisappear(_:))).map { _ in return false }
    return Observable.merge(visible, invisible)
  }
}

public extension CollectionViewContainer where Self: UIViewController, Self: DisposableContainer
& PullToRefreshContainer & ViewStateContainer {

  func setupContainerView(with refreshControl: UIRefreshControl?) {
    view.addSubview(containerView)
    if let refreshControl = refreshControl {
      refreshControl.rx
        .controlEvent(.valueChanged)
        .bind(to: pullToRefreshSubject)
        .disposed(by: disposeBag)

      containerView.refreshControl = refreshControl
      loaderViewSubject.filter { !$0 } .bind(to: refreshControl.rx.isRefreshing).disposed(by: disposeBag)
    }
    containerView.showsVerticalScrollIndicator = false
    containerView.showsHorizontalScrollIndicator = false
    if #available(iOS 11.0, *) {
      containerView.contentInsetAdjustmentBehavior = .never
    }

    // FIXME: not so sure that we still need this
    containerView.rx.observe(CGRect.self, "bounds")
      .observeOn(MainScheduler.asyncInstance)
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] _ in
        self?.containerView.collectionViewLayout.invalidateLayout()
      })
      .disposed(by: disposeBag)
  }
}
