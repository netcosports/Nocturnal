//
//  CustomNavigationable.swift
//  Nocturnal
//
//  Created by Sergei Mikhan on 11.03.21.
//

import RxSwift

public protocol CustomNavigationable: class {

  var inset: UIEdgeInsets { get }

  var fromBackgroundView: UIView { get }
  var toBackgroundView: UIView { get }

  var fromHost: NavigationBarHostable? { get set }
  var toHost: NavigationBarHostable? { get set }

  var fromContainer: UIView { get }
  var toContainer: UIView { get }

  func startTransition(from fromHost: NavigationBarHostable?, to toHost: NavigationBarHostable?)
  func updateTransition(with progress: CGFloat)
  func finishTransition()
}

extension CustomNavigationable where Self: UIView {

  public var fromAlpha: CGFloat {
    (try? (fromHost as? NavigationBarTransparency)?.currentNavigationBarTransparency.value()) ?? 1.0
  }

  public var toAlpha: CGFloat {
    (try? (toHost as? NavigationBarTransparency)?.currentNavigationBarTransparency.value()) ?? 1.0
  }

  public func startTransition(
    from fromHost: NavigationBarHostable?,
    to toHost: NavigationBarHostable?
  ) {
    self.fromHost = fromHost
    self.toHost = toHost

    toBackgroundView.superview?.bringSubviewToFront(toBackgroundView)
    fromBackgroundView.superview?.bringSubviewToFront(fromBackgroundView)
    fromContainer.superview?.bringSubviewToFront(fromContainer)
    toContainer.superview?.bringSubviewToFront(toContainer)

    fromBackgroundView.alpha = self.fromAlpha
    fromContainer.alpha = 1.0
    toContainer.alpha = 0.0

    self.layoutIfNeeded()
  }

  public func updateTransition(with progress: CGFloat) {
    fromBackgroundView.alpha = self.fromAlpha * (1.0 - progress)
    fromContainer.alpha = 1.0 - progress
    toBackgroundView.alpha = self.toAlpha * progress
    toContainer.alpha = progress
  }

  public func finishTransition() {
    fromContainer.subviews.forEach { $0.removeFromSuperview() }

    fromContainer.alpha = 0.0
    toBackgroundView.alpha = self.toAlpha
    toContainer.alpha = 1.0
  }

  public func layout(host: NavigationBarHostable?, into view: UIView) {
    guard let host = host else { return }

    view.frame = self.bounds
    let leading = host.leadingViews
    let trailing = host.trailingViews

    let width = self.width - inset.left - inset.right
    let height = self.height - inset.top - inset.bottom

    var leadingX: CGFloat = inset.left
    var trailingX: CGFloat = width - inset.right

    let y = self.inset.top

    leading.forEach {
      $0.view.frame = CGRect(x: leadingX, y: y, width: $0.width, height: height)
      leadingX += $0.width
    }

    trailing.forEach {
      $0.view.frame = CGRect(x: trailingX - $0.width, y: y, width: $0.width, height: height)
      trailingX -= $0.width
    }

    guard let title = host.titleView else {
      return
    }
    let availableSpace = trailingX - leadingX
    if availableSpace > title.width {
      // place in center
      title.view.frame = CGRect(x: 0.5 * (width - title.width), y: y, width: title.width, height: height)
    } else {
      // fill all available space
      title.view.frame = CGRect(x: leadingX, y: y, width: availableSpace, height: height)
    }
  }

  public func integrate(host: NavigationBarHostable?, into view: UIView, backgroundView: UIView) {
    guard let host = host else { return }
    view.subviews.forEach { $0.removeFromSuperview() }
    if backgroundView.superview == nil {
      addSubview(backgroundView)
    }
    backgroundView.backgroundColor = host.backgroundColor

    if view.superview == nil {
      self.addSubview(view)
    }
    host.leadingViews.forEach {
      view.addSubview($0.view)
    }
    host.trailingViews.forEach {
      view.addSubview($0.view)
    }
    guard let title = host.titleView else {
      return
    }
    view.addSubview(title.view)
    setNeedsLayout()
  }
}
