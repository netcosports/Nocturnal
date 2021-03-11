//
//  PreferredNavigationBarTransparency.swift
//  CoreUI
//
//  Created by Sergei Mikhan on 2/14/20.
//

import RxSwift
import RxCocoa

public protocol PreferredNavigationBarTransparency: class {

  var preferredNavigationBarTransparency: NavigationBarTransparencySupport { get }

  var transparentNavigationBar: TransparentNavigationBar? { get }
}

public extension PreferredNavigationBarTransparency {

  var preferredNavigationBarTransparency: NavigationBarTransparencySupport {
    .disabled
  }
}

public extension PreferredNavigationBarTransparency where Self: UIViewController {

  var transparentNavigationBar: TransparentNavigationBar? {
    self.navigationController?.navigationBar as? TransparentNavigationBar
  }
}

public extension PreferredNavigationBarTransparency where Self: UIViewController & NavigationBarTransparency &
                                                                Lifecycle & DisposableContainer {

  func setupTransparencyHost() {
    automaticallyAdjustsScrollViewInsets = false
    edgesForExtendedLayout = .all
    extendedLayoutIncludesOpaqueBars = true

    // NOTE: presetup value of currentNavigationBarTransparency with correct one
    // based on client's value provided over preferredNavigationBarTransparency
    let transparency: CGFloat = preferredNavigationBarTransparency == .enabled ? 0.0 : 1.0
    currentNavigationBarTransparency.onNext(transparency)

    visibility.do(onNext: { [weak self] visible in
      if visible { self?.setNeedsStatusBarAppearanceUpdate() }
    }).filter { $0 }
      // NOTE: we need to perform this action with asyncInstance
      // to let parent add this controller as a child
      .observeOn(MainScheduler.asyncInstance)
      .flatMapLatest { [weak self] _ -> Observable<CGFloat> in
      // NOTE: navigationBar become available only in viewwillappear
        guard let navigationBar = self?.transparentNavigationBar else {
        return .empty()
      }
      return navigationBar.transparencySubject.asObservable()
        .filter({ [weak self] _ in self?.isHostApplingTransparency == true })
    }.bind(to: currentNavigationBarTransparency)
     .disposed(by: disposeBag)

    let visible = self.rx
      .sentMessage(#selector(UIViewController.viewDidAppear(_:)))
      .map { _ in true }

    let invisible = self.rx
      .sentMessage(#selector(UIViewController.viewDidDisappear(_:)))
      .map { _ in false }

    Observable.merge(visible, invisible).subscribe(onNext: { [weak self] visible in
       // NOTE: generally if we are in UINavigationController, it will update isHostApplingTransparency value
       // but in some case (set rootViewController directly for example) we need to start apply transparency manually
       self?.isHostApplingTransparency = visible
     }).disposed(by: disposeBag)

    navigationController?.rx.willShow.subscribe(onNext: { [weak self] viewControllerAndAnimated in
      guard let navigationController = self?.navigationController else { return }
      let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
      viewControllerAndAnimated.viewController.navigationItem.backBarButtonItem = item
      if let coordinator = navigationController.topViewController?.transitionCoordinator {
        coordinator.notifyWhenInteractionChanges { context in
          (navigationController as? TransparentNavigationBarSupport)?.finalizeInteractiveTransition(context.isCancelled)
        }
      }
    }).disposed(by: disposeBag)
  }
}

public typealias NavigationBarTransparencyHost = NavigationBarTransparency & PreferredNavigationBarTransparency
