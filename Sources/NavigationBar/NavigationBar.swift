//
//  NavigationBar.swift
//  Nocturnal
//
//  Created by Sergei Mikhan on 3/9/21.
//

import RxSwift

public class NavigationBar: UIView, CustomNavigationable, TransparentNavigationBar {

  private let disposeBag = DisposeBag()

  public let fromBackgroundView = UIView()
  public let toBackgroundView = UIView()

  init() {
    super.init(frame: .zero)
    transparencySubject.subscribe(onNext: { [weak self] progress in
      self?.toBackgroundView.alpha = progress
    }).disposed(by: disposeBag)
  }

  required init?(coder: NSCoder) {
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

  public var inset: UIEdgeInsets {
    .init(top: UIApplication.shared.statusBarFrame.height, left: 0.0, bottom: 0.0, right: 0.0)
  }

  public var fromContainer = UIView()
  public var toContainer = UIView()

  public override func layoutSubviews() {
    super.layoutSubviews()

    toBackgroundView.frame = self.bounds
    fromBackgroundView.frame = self.bounds

    layout(host: fromHost, into: fromContainer)
    layout(host: toHost, into: toContainer)
  }

  public var fromHost: NavigationBarHostable? {
    didSet {
      self.integrate(host: fromHost, into: fromContainer, backgroundView: fromBackgroundView)
    }
  }
  public var toHost: NavigationBarHostable? {
    didSet {
      self.integrate(host: toHost, into: toContainer, backgroundView: toBackgroundView)
    }
  }
}
