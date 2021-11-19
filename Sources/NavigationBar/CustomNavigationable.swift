//
//  CustomNavigationable.swift
//  Nocturnal
//
//  Created by Sergei Mikhan on 11.03.21.
//

import RxSwift

public protocol CustomNavigationable: class {

  var isInTransition: Bool { get set }

  var inset: UIEdgeInsets { get }

  var fromBackgroundView: UIImageView { get }
  var toBackgroundView: UIImageView { get }

  var fromHost: NavigationBarHostable? { get set }
  var toHost: NavigationBarHostable? { get set }

  var fromContainer: UIView { get }
  var toContainer: UIView { get }

  func startTransition(from fromHost: NavigationBarHostable?, to toHost: NavigationBarHostable?)
  func updateTransition(with progress: CGFloat)
  func finishTransition(isCanceled: Bool)
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
    if isInTransition {
      return
    }

    isUserInteractionEnabled = false
    isInTransition = true
    subviews.forEach { $0.removeFromSuperview() }

    self.fromHost = fromHost
    self.toHost = toHost

    fromBackgroundView.superview?.sendSubviewToBack(fromBackgroundView)
    toBackgroundView.superview?.sendSubviewToBack(toBackgroundView)

    fromContainer.superview?.bringSubviewToFront(fromContainer)
    toContainer.superview?.bringSubviewToFront(toContainer)

    fromBackgroundView.alpha = self.fromAlpha
    toBackgroundView.alpha = isSameBackground ? self.toAlpha : 0.0
    fromContainer.alpha = 1.0
    toContainer.alpha = 0.0

    self.setNeedsLayout()
    self.layoutIfNeeded()
  }

  public func updateTransition(with progress: CGFloat) {
    fromBackgroundView.alpha = self.fromAlpha * (1.0 - progress)
    fromContainer.alpha = 1.0 - progress
    toBackgroundView.alpha = isSameBackground ? self.toAlpha : self.toAlpha * progress
    toContainer.alpha = progress
  }

  public func finishTransition(isCanceled: Bool) {
    isInTransition = false
    isUserInteractionEnabled = true

    let targetContainer: UIView
    let targetBackground: UIView
    let targetAlpha: CGFloat

    let otherContainer: UIView
    let otherBackground: UIView
    let otherAlpha: CGFloat = 0.0

    if isCanceled {
      targetContainer = fromContainer
      targetBackground = fromBackgroundView
      targetAlpha = self.fromAlpha

      otherContainer = toContainer
      otherBackground = toBackgroundView
    } else {
      targetContainer = toContainer
      targetBackground = toBackgroundView
      targetAlpha = self.toAlpha

      otherContainer = fromContainer
      otherBackground = fromBackgroundView
    }

    otherContainer.subviews.forEach { $0.removeFromSuperview() }

    otherBackground.alpha = otherAlpha
    otherContainer.alpha = otherAlpha

    targetBackground.alpha = targetAlpha
    targetContainer.alpha = 1.0
  }

  public func layout(host: NavigationBarHostable?, into view: UIView) {
    guard let host = host, let item = host.customNavigationItem else { return }

    view.frame = self.bounds
    let leading = item.leadingViews
    let trailing = item.trailingViews

    let width = self.width - inset.left - inset.right
    let height = item.height

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
    
    guard let title = item.titleView else {
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

  public func integrate(host: NavigationBarHostable?, into view: UIView, backgroundView: UIImageView) {
    guard let host = host, let item = host.customNavigationItem else { return }
    view.subviews.forEach { $0.removeFromSuperview() }
    addSubview(backgroundView)
    addSubview(view)

    if let background = item.background {
      switch background {
      case .color(let color):
        backgroundView.backgroundColor = color
        backgroundView.image = nil
      case .image(let image):
        backgroundView.image = image
        backgroundView.backgroundColor = nil
      }
    }
    
    item.leadingViews.forEach {
      view.addSubview($0.view)
    }
    item.trailingViews.forEach {
      view.addSubview($0.view)
    }
    guard let title = item.titleView else {
      return
    }
    view.addSubview(title.view)
    setNeedsLayout()
  }
  
  private var isSameBackground: Bool {
    if let fromImage = fromBackgroundView.image, let toImage = toBackgroundView.image {
      return fromImage.isEqual(toImage)
    }
    if let fromColor = fromBackgroundView.backgroundColor, let toColor = toBackgroundView.backgroundColor {
      return fromColor.isEqual(toColor)
    }
    return false
  }
}
