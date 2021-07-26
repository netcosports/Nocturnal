//
//  NavigationBarTransparency.swift
//  CoreUI
//
//  Created by Sergei Mikhan on 2/10/20.
//

import UIKit
import RxSwift
import RxCocoa

public enum NavigationBarTransparencySupport {
  case enabled, disabled
}

public protocol TransparentNavigationBar {

  var transparencySubject: PublishSubject<CGFloat> { get }

  func startTransition(from fromViewController: UIViewController?, to toViewController: UIViewController?)
  func updateTransition(with progress: CGFloat)
  func finishTransition(isCanceled: Bool)

  var currentHeight: CGFloat { get }
  var frameToIgnore: CGRect { get set }
}

public extension TransparentNavigationBar {

  func startTransition(from fromViewController: UIViewController?, to toViewController: UIViewController?) {

  }

  func updateTransition(with progress: CGFloat) {

  }

  func finishTransition(isCanceled: Bool) {

  }
}

public extension TransparentNavigationBar {

  func apply(transparency: NavigationBarTransparencySupport) {
    switch transparency {
    case .enabled:
      self.transparencySubject.onNext(0)
    case .disabled:
       self.transparencySubject.onNext(1)
    }
  }

  func applyInteractive(from: NavigationBarTransparency?, to: NavigationBarTransparency?, value: CGFloat) {
    if let fromVC = try? from?.currentNavigationBarTransparency.value(),
      let toVC = try? to?.currentNavigationBarTransparency.value() {
      let result = fromVC + (toVC - fromVC) * value
      self.transparencySubject.onNext(result)
    }
  }
}

public extension UINavigationBar {

  func backgroundViewClass() -> AnyClass? {
    let className: String
    if #available(iOS 10.0, *) {
      className = "_UIBarBackground"
    } else {
      className = "_UINavigationBarBackground"
    }
    return NSClassFromString(className)
  }
}

public extension TransparentNavigationBar where Self: UINavigationBar & DisposableContainer {

  func setupTranparent(backImage: UIImage?, tint: UIColor, tranparencyChangeClosure: @escaping (CGFloat) -> Void) {
    setBackgroundImage(UIImage(), for: .default)
    backIndicatorImage = backImage
    backIndicatorTransitionMaskImage = backImage
    shadowImage = UIImage()
    clipsToBounds = false
    tintColor = tint
    isTranslucent = true
    transparencySubject.asObservable().subscribe(onNext: { value in
      tranparencyChangeClosure(max(0.0, min(1.0, value)))
    }).disposed(by: disposeBag)
  }
}

public protocol NavigationBarTransparency: class {

  var currentNavigationBarTransparency: BehaviorSubject<CGFloat> { get }
  var isHostApplingTransparency: Bool { get set }
}

public extension NavigationBarTransparency where Self: UIViewController & Scrolling & DisposableContainer & Lifecycle {

  func connectNavBarVisibilityToScrollView(showNavbarWithEmptyContent: Bool = true) {
    visibility.filter { $0 }.take(1).flatMap { [weak self] _ -> Observable<CGFloat> in
      guard let scrollView = self?.scrollView, let hideFactor = self?.hideFactor else { return .empty() }
			return scrollView.rx.scrollProgressInContainer(showNavbarWithEmptyContent: showNavbarWithEmptyContent,
																										 hideFactor: hideFactor)
    }
    .filter({ [weak self] _ in self?.isHostApplingTransparency == true })
    .subscribe(onNext: { [weak self] transparency in
      guard let navigationBar = (self?.navigationController as? TransparentNavigationBarSupport)?.customNavigationBar else {
        return
      }
      navigationBar.transparencySubject.onNext(transparency)
    }).disposed(by: disposeBag)
  }
}
