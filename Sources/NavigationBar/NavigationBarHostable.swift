//
//  NavigationBarHostable.swift
//  Nocturnal
//
//  Created by Sergei Mikhan on 11.03.21.
//

import RxSwift

public protocol BarItemViewable {
  var view: UIView { get }
  var width: CGFloat { get }
  var respectsBarTransparency: Bool { get }
}

public extension BarItemViewable {
  var respectsBarTransparency: Bool {
    return false
  }
}

@frozen
public enum NavigationItemBackground {
  case color(UIColor)
  case image(UIImage)
}

public protocol NavigationItemable {
  var height: CGFloat { get }
  var background: NavigationItemBackground? { get }
  var titleView: BarItemViewable? { get }
  var leadingViews: [BarItemViewable] { get }
  var trailingViews: [BarItemViewable] { get }
}

public extension NavigationItemable {
  var barViewableItems: [BarItemViewable] {
    return leadingViews + trailingViews + (titleView.map{[$0]} ?? [])
  }
}

public struct NavigationItem: NavigationItemable {
  public let height: CGFloat
  public let background: NavigationItemBackground?
  public let titleView: BarItemViewable?
  public let leadingViews: [BarItemViewable]
  public let trailingViews: [BarItemViewable]

  public init(
    height: CGFloat,
    background: NavigationItemBackground?,
    titleView: BarItemViewable?,
    leadingViews: [BarItemViewable],
    trailingViews: [BarItemViewable]
  ) {
    self.height = height
    self.background = background
    self.titleView = titleView
    self.leadingViews = leadingViews
    self.trailingViews = trailingViews
  }
}

public protocol NavigationBarHostable: class {
  var customNavigationItem: NavigationItemable? { get }
}

public struct BarItemView: BarItemViewable {
  public let view: UIView
  public let width: CGFloat
  public let respectsBarTransparency: Bool

  public init(view: UIView, width: CGFloat, respectsBarTransparency: Bool = false) {
    self.view = view
    self.width = width
    self.respectsBarTransparency = respectsBarTransparency
  }
}

