//
//  CollectionViewContainer.swift
//  Nocturnal
//
//  Created by Sergei Mikhan on 12/28/19.
//

import UIKit
import Astrolabe
import Sundial
import RxSwift
import RxCocoa

public protocol CollectionViewContainer {
  associatedtype Source: ReusableSource where Source.Container == UICollectionView
  var containerView: CollectionView<Source> { get }
}

extension CollectionView: CollectionViewContainer {
  public typealias Source = T
  public var containerView: CollectionView<T> {
    return self
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

public extension AutoscrollContainer where Self: DisposableContainer & CollectionViewContainer {

  func subscribeToAutoscrollEvents() {
    let autoScrollObservable = autoScrollSubject.asObservable().observeOn(MainScheduler.instance)
    autoScrollObservable.flatMap { [weak self] target -> Observable<Void> in
      guard let self = self else { return .empty() }
      var index: IndexPath?
      switch target.target {
      case .cellId(let cellId):
        index = self.containerView.source.indexPath(for: cellId)
      case .indexPath(let indexPath):
        index = indexPath
      }
      guard let emptyViewLayout = self.containerView.collectionViewLayout as? PreparedLayout else { return .empty()
      }
      let sections = self.containerView.source.sections
      if let index = index, index.section < sections.count && index.item < sections[index.section].cells.count {
        self.containerView.scroll(to: target)
        return .empty()
      }
      return emptyViewLayout.readyObservable
        .filter { [weak self] _ in
          return (self?.containerView.source.sections.count ?? 0) > 0
        }
        .filter { [weak self] _ in
          guard let self = self else { return false }
          let sections = self.containerView.source.sections
          if index == nil, case .cellId(let cellId) = target.target {
            index = self.containerView.source.indexPath(for: cellId)
            assert(index != nil, "Can not find cell with id '\(cellId)'")
          }
          guard let index = index else { return false }
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
  }
}

extension UIViewController: Lifecycle {

  public var visibility: Observable<Bool> {
    let visible = self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:))).map { _ in return true}
    let invisible = self.rx.sentMessage(#selector(UIViewController.viewDidDisappear(_:))).map { _ in return false }
    return Observable.merge(visible, invisible)
  }
}
