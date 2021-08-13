//
//  NavigationBar.swift
//  Nocturnal
//
//  Created by Sergei Mikhan on 3/9/21.
//

import RxSwift

open class NavigationBar: UIView, CustomNavigationable, TransparentNavigationBar {

  public var isInTransition = false

  private let disposeBag = DisposeBag()

  public let fromBackgroundView = UIView()
  public let toBackgroundView = UIView()

  public var visibleWhenInTop = true

  init() {
    super.init(frame: .zero)
    transparencySubject.subscribe(onNext: { [weak self] progress in
      self?.toBackgroundView.alpha = self?.visibleWhenInTop == true ? progress : 1.0 - progress
    }).disposed(by: disposeBag)
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func startTransition(
    from fromViewController: UIViewController?,
    to toViewController: UIViewController?
  ) {
    startTransition(
      from: fromViewController as? NavigationBarHostable,
      to: toViewController as? NavigationBarHostable
    )
  }

  public var transparencySubject = PublishSubject<CGFloat>()

  open var inset: UIEdgeInsets {
    .init(top: UIApplication.shared.statusBarFrame.height, left: 0.0, bottom: 0.0, right: 0.0)
  }

  public var fromContainer = UIView()
  public var toContainer = UIView()

  open override func layoutSubviews() {
    super.layoutSubviews()

    toBackgroundView.frame = self.bounds
    fromBackgroundView.frame = self.bounds

    layout(host: fromHost, into: fromContainer)
    layout(host: toHost, into: toContainer)
  }

  public weak var fromHost: NavigationBarHostable? {
    didSet {
      self.integrate(host: fromHost, into: fromContainer, backgroundView: fromBackgroundView)
    }
  }
  public weak var toHost: NavigationBarHostable? {
    didSet {
      self.integrate(host: toHost, into: toContainer, backgroundView: toBackgroundView)
    }
  }

  public var currentHeight: CGFloat {
    guard let toHeight = self.toHost?.customNavigationItem?.height else {
      return 0.0
    }

    guard let fromHeight = self.fromHost?.customNavigationItem?.height else {
      return toHeight
    }

    // FIXME: need to find more proper way to get progres
    let progress = toContainer.alpha
    return fromHeight + (toHeight - fromHeight) * progress
  }

  open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard let view = super.hitTest(point, with: event) else {
      return nil
    }
    return view as? UIControl
  }
}
