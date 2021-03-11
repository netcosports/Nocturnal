//
//  NavigationController.swift
//  Demo
//
//  Created by Sergei Mikhan on 7.03.21.
//  Copyright © 2021 NetcoSports. All rights reserved.
//

import Nocturnal

import RxSwift

public enum Dimens {
  static let navigationBarHeight: CGFloat = 88.0
}

// MARK: - Implementation
public final class NavigationController: UINavigationController, TransparentNavigationBarSupport, DisposableContainer {
  public let disposeBag = DisposeBag()
  public var isGesturePopShouldBegin = false
  public weak var fromViewController: NavigationBarTransparencyController?
  public weak var toViewController: NavigationBarTransparencyController?

  private let navBar = NavigationBar()

  public var customNavigationBar: TransparentNavigationBar? {
    return navBar
  }

  // MARK: - Init
  public required init() {
    super.init(navigationBarClass: UINavigationBar.self, toolbarClass: nil)
  }

  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .black
    view.addSubview(navBar)

    setNavigationBarHidden(true, animated: false)
    setupTransparentNavigationBar()
    interactivePopGestureRecognizer?.delegate = self
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    navBar.pin.top().height(UIApplication.shared.statusBarFrame.height + Dimens.navigationBarHeight).horizontally()
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    applyCurrentTransparency()
  }

  // MARK: - Push/pop
  @discardableResult public override func popViewController(animated: Bool) -> UIViewController? {
    interactivePop()
    return super.popViewController(animated: animated)
  }

  @discardableResult public override func popToRootViewController(animated: Bool) -> [UIViewController]? {
    interactivePopToRoot()
    return super.popToRootViewController(animated: animated)
  }

  public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
    interactivePush(viewController)
    super.pushViewController(viewController, animated: animated)
  }

  public override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
    interactiveSet(viewControllers)
    super.setViewControllers(viewControllers, animated: animated)
  }

  public func replaceTop(with viewController: UIViewController) {
    var viewControllers = self.viewControllers
    if viewControllers.count > 1 {
      viewControllers.removeLast()
      viewControllers.append(viewController)
      setViewControllers(viewControllers, animated: true)
    } else {
      pushViewController(viewController, animated: true)
    }
  }

  // MARK: - Overrides
  public override var childForStatusBarStyle: UIViewController? {
    return activeViewController
  }

  public override var childForStatusBarHidden: UIViewController? {
    return activeViewController
  }

  public override var shouldAutorotate: Bool {
    return activeViewController?.shouldAutorotate ?? true
  }

  public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return activeViewController?.supportedInterfaceOrientations ?? .all
  }

  public override var preferredStatusBarStyle: UIStatusBarStyle {
    return activeViewController?.preferredStatusBarStyle ?? .default
  }

  @available(iOS 11.0, *)
  public override var prefersHomeIndicatorAutoHidden: Bool {
    return activeViewController?.prefersHomeIndicatorAutoHidden ?? true
  }
}

// MARK: - Interactive navigation item apply
extension NavigationController: UIGestureRecognizerDelegate {
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return gestureRecognizer is UIScreenEdgePanGestureRecognizer
  }

  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return gestureRecognizer is UIScreenEdgePanGestureRecognizer
  }

  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard gestureRecognizer == interactivePopGestureRecognizer else { return true }
    guard viewControllers.count > 1 else { return false }
    isGesturePopShouldBegin = true
    gestureRecognizer.removeTarget(self, action: #selector(edgeGesture(_:)))
    gestureRecognizer.addTarget(self, action: #selector(edgeGesture(_:)))
    return true
  }

  @objc private func edgeGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
    self.handle(gesture: gesture)
  }
}
