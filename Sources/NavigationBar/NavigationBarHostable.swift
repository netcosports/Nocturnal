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

public protocol NavigationBarHostable {
  var backgroundColor: UIColor? { get }

  var titleView: BarItemViewable? { get }
  var leadingViews: [BarItemViewable] { get }
  var trailingViews: [BarItemViewable] { get }
}

public struct BarItemView: BarItemViewable {
  public let view: UIView
  public let width: CGFloat

  public init(view: UIView, width: CGFloat) {
    self.view = view
    self.width = width
  }
}

