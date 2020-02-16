//
//  AutoScrollTarget.swift
//  CoreUI
//
//  Created by Sergei Mikhan on 12/27/19.
//

import UIKit
import Astrolabe

import RxSwift
import RxCocoa

public struct AutoScrollTarget {

  public enum Target {
    case indexPath(IndexPath)
    case cellId(String)
  }

  public let target: Target
  public let position: TargetScrollPosition
  public let animated: Bool
  public let keepInsideSafeArea: Bool

  public init(target: Target,
              position: TargetScrollPosition,
              animated: Bool,
              keepInsideSafeArea: Bool = true) {
    self.target = target
    self.position = position
    self.animated = animated
    self.keepInsideSafeArea = keepInsideSafeArea
  }
}

public extension CollectionView {

  // swiftlint:disable:next cyclomatic_complexity function_body_length
  func scroll(to target: AutoScrollTarget) {
    let index: IndexPath
    switch target.target {
    case .cellId(let cellId):
      guard let indexPathForItem = self.source.indexPath(for: cellId) else {
        assertionFailure("Can not find cell with id '\(cellId)'")
        return
      }
      index = indexPathForItem
    case .indexPath(let indexPath):
      index = indexPath
    }
    let position = target.position
    let animated = target.animated
    let keepInsideSafeArea = target.keepInsideSafeArea

    guard index.section < self.source.sections.count,
      index.item < self.source.sections[index.section].cells.count else { return }
    guard let layout = self.collectionViewLayout as? UICollectionViewFlowLayout else { return }
    guard let attributes = layout.layoutAttributesForItem(at: index) else { return }

    var point: CGPoint
    if layout.scrollDirection == .vertical {
      switch position {
      case .center:
        point = CGPoint(x: 0.0, y: attributes.frame.midY - 0.5 * (self.frame.height - attributes.frame.height))
      case .end:
        point = CGPoint(x: 0.0, y: attributes.frame.minY + self.frame.height - attributes.frame.height)
      case .start:
        var y = attributes.frame.minY
        if #available(iOS 11.0, *), keepInsideSafeArea, let view = self.source.hostViewController?.view {
          y -= view.safeAreaInsets.top + layout.minimumLineSpacing
        }
        point = CGPoint(x: 0.0, y: y)
      }
      if point.y + self.frame.height > (layout.collectionViewContentSize.height + self.contentInset.bottom) {
        point = CGPoint(x: 0.0, y: layout.collectionViewContentSize.height - self.height - 1.0)
      } else if point.y < 0.0 {
        point = CGPoint(x: 0.0, y: -self.contentInset.top)
      }
    } else {
      switch position {
      case .center:
        // NOTE: looks weird, but the only way I can imagine to handle autoaligned layout
        point = CGPoint(x: attributes.frame.minX - self.contentInset.left, y: 0.0)
      case .end:
        point = CGPoint(x: attributes.frame.minX + self.frame.width - attributes.frame.width, y: 0.0)
      case .start:
        var x = attributes.frame.minX
        if #available(iOS 11.0, *), keepInsideSafeArea, let view = self.source.hostViewController?.view {
          x -= view.safeAreaInsets.left + layout.minimumInteritemSpacing
        }
        point = CGPoint(x: x, y: 0.0)
      }
      if point.x + self.frame.width > (layout.collectionViewContentSize.width + self.contentInset.right) {
        point = CGPoint(x: layout.collectionViewContentSize.width - self.width - 1.0, y: 0.0)
      }
    }
    self.setContentOffset(point, animated: animated)
  }
}
