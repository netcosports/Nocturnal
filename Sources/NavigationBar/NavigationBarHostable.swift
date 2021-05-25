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
}

public protocol NavigationItemable {
  var height: CGFloat { get }
  var backgroundColor: UIColor? { get }
  var titleView: BarItemViewable? { get }
  var leadingViews: [BarItemViewable] { get }
  var trailingViews: [BarItemViewable] { get }
}

public struct NavigationItem: NavigationItemable {
  public let height: CGFloat
  public let backgroundColor: UIColor?
  public let titleView: BarItemViewable?
  public let leadingViews: [BarItemViewable]
  public let trailingViews: [BarItemViewable]

  public init(
    height: CGFloat,
    backgroundColor: UIColor?,
    titleView: BarItemViewable?,
    leadingViews: [BarItemViewable],
    trailingViews: [BarItemViewable]
  ) {
    self.height = height
    self.backgroundColor = backgroundColor
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

  public init(view: UIView, width: CGFloat) {
    self.view = view
    self.width = width
  }
}

