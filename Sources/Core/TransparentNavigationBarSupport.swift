//
//  TransparentNavigationBarSupport.swift
//  CoreUI
//
//  Created by Sergei Mikhan on 2/14/20.
//

import RxSwift

public extension UINavigationController {

  var activeViewController: UIViewController? {

    if let presentedViewController = presentedViewController, !presentedViewController.isBeingDismissed {
      return presentedViewController
    }
    return topViewController
  }

  typealias NavigationBarWithTransparency = UINavigationBar & TransparentNavigationBar
  var customNavigationBar: NavigationBarWithTransparency? {
    return navigationBar as? NavigationBarWithTransparency
  }
}

public protocol TransparentNavigationBarSupport: class {

  typealias NavigationBarTransparencyController = NavigationBarTransparency & UIViewController

  var isGesturePopShouldBegin: Bool { get set }

  var fromViewController: NavigationBarTransparencyController? { get set }
  var toViewController: NavigationBarTransparencyController? { get set }

  func startInteractiveTransition()
  func updateInteractiveTransition(_ progress: CGFloat)
  func finalizeInteractiveTransition(_ isCanceled: Bool)
}

public extension TransparentNavigationBarSupport where Self: UINavigationController {

  func interactiveChange(toController: NavigationBarTransparencyController?,
                         fromController: NavigationBarTransparencyController?) {
    toViewController = toController
    fromViewController = fromController
    fromViewController?.isHostApplingTransparency = false
    toViewController?.loadViewIfNeeded()
    if let toVC = toViewController,
      let value = try? toVC.currentNavigationBarTransparency.value(),
      !isGesturePopShouldBegin {
      UIView.animate(withDuration: 0.25, animations: {
        self.customNavigationBar?.transparencySubject.onNext(value)
      }, completion: { _ in
        toVC.isHostApplingTransparency = true
      })
    }
  }

  func interactivePush(_ viewController: UIViewController) {
    interactiveChange(toController: viewController as? NavigationBarTransparencyController,
                      fromController: topViewController as? NavigationBarTransparencyController)
  }

  func interactiveSet(_ viewControllers: [UIViewController]) {
    interactiveChange(toController: viewControllers.last as? NavigationBarTransparencyController,
                      fromController: topViewController as? NavigationBarTransparencyController)
  }

  func interactivePopToRoot() {
    interactiveChange(toController: viewControllers.first as? NavigationBarTransparencyController,
                      fromController: topViewController as? NavigationBarTransparencyController)
  }

  func interactivePop() {
    let toController = viewControllers[safe: viewControllers.count - 2] as? NavigationBarTransparencyController
    interactiveChange(toController: toController,
                      fromController: topViewController as? NavigationBarTransparencyController)
  }

  func handle(gesture: UIScreenEdgePanGestureRecognizer) {
    guard let view = gesture.view, view.bounds.size.width > 0.0 else {
      return
    }
    let progress = (gesture.translation(in: view).x / view.bounds.size.width).clamp(0.0, 1.0)
    switch gesture.state {
    case .began:
      startInteractiveTransition()
    case .changed:
      updateInteractiveTransition(progress)

    default: break
    }
  }

  func startInteractiveTransition() {
    fromViewController?.isHostApplingTransparency = false
    toViewController?.isHostApplingTransparency = false
  }

  func updateInteractiveTransition(_ progress: CGFloat) {
    customNavigationBar?.applyInteractive(from: fromViewController, to: toViewController, value: progress)
  }

  func finalizeInteractiveTransition(_ isCanceled: Bool) {
    let progress: CGFloat = isCanceled ? 0.0 : 1.0
    customNavigationBar?.applyInteractive(from: fromViewController, to: toViewController, value: progress)
    fromViewController?.isHostApplingTransparency = isCanceled
    toViewController?.isHostApplingTransparency = !isCanceled
    isGesturePopShouldBegin = false
  }

  func applyCurrentTransparency() {
    guard let topController = (topViewController as? NavigationBarTransparencyController) else {
      return
    }
    topController.loadViewIfNeeded()
    guard let tranparency = try? topController.currentNavigationBarTransparency.value() else {
      return
    }
    customNavigationBar?.transparencySubject.onNext(tranparency)
  }
}
