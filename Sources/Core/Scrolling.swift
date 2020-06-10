//
//  Scrolling.swift
//  CoreUI
//
//  Created by Sergei Mikhan on 2/10/20.
//

import Alidade

import RxSwift
import RxCocoa

public extension Reactive where Base: UIScrollView {

	func scrollProgressInContainer(showNavbarWithEmptyContent: Bool = true,
																 hideFactor: CGFloat) -> Observable<CGFloat> {
    let offset = base.rx.contentOffset
      .map { $0.y }
    let contentSize = base.rx
      .observe(CGSize.self, #keyPath(UICollectionView.contentSize))
      .distinctUntilChanged()

    return Observable.combineLatest(offset, contentSize)
      .map { [weak base] offset, contentSize in
        guard let base = base, let contentSize = contentSize else { return 1.0 }
        if contentSize.height > base.height {
          return min(offset / (hideFactor * (base.height > 0.0 ? base.height : 1.0)), 1.0)
        } else {
          return showNavbarWithEmptyContent ? 1.0 : 0.0
        }
      }
  }
}

public protocol Scrolling {

  var scrollView: UIScrollView { get }
	var hideFactor: CGFloat { get }
}

public extension Scrolling {
	var hideFactor: CGFloat { 0.4 }
}

public extension Scrolling where Self: CollectionViewContainer {

  var scrollView: UIScrollView {
    return containerView
  }
}
