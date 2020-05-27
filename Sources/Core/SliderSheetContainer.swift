//
//  SliderSheetContainer.swift
//  Nocturnal
//
//  Created by Sergei Mikhan on 3/31/20.
//

import Nocturnal

import RxSwift
import RxCocoa
import RxGesture

public protocol SliderSheetContainer: class {
  var sliderSheetHeight: CGFloat { get set }
  func enableSliderSheet(for sliderSheetView: UIView, in range: ClosedRange<CGFloat>, anchor: Anchor,
  initialHeight: CGFloat?)
}

public enum Anchor {
  case top
  case bottom
}

private enum AnimationTarget {
  case start
  case end
}

public extension SliderSheetContainer where Self: UIViewController & DisposableContainer {

  func enableSliderSheet(for sliderSheetView: UIView,
                         in range: ClosedRange<CGFloat>,
                         anchor: Anchor,
                         initialHeight: CGFloat? = nil) {

    sliderSheetHeight = initialHeight ?? range.upperBound

    let began = sliderSheetView.rx.panGesture().when(.began)
      .map { [weak self] _ in self?.sliderSheetHeight ?? 0.0 }

    let ended = sliderSheetView.rx.panGesture().when(.ended, .cancelled)
    .do(onNext: { [weak self] panGesure in
      guard let self = self else { return }
      let velocity = panGesure.velocity(in: self.view)
      let target: AnimationTarget
      switch anchor {
      case .bottom:
        target = velocity.y > 0.0 ? .end : .start
      case .top:
        target = velocity.y > 0.0 ? .start : .end
      }
      self.animateView(to: target, with: velocity, in: range)
    })

    let changed = sliderSheetView.rx.panGesture().when(.changed)
    .withLatestFrom(began, resultSelector: { ($0, $1) })
    .do(onNext: { [weak self] panGesure, startTranslation in
      self?.handle(panGesure: panGesure, startTranslation: startTranslation,
                   range: range, anchor: anchor)
    }).map { $0.0 }

    Observable.merge(changed, ended).subscribe().disposed(by: disposeBag)
  }
}

private extension SliderSheetContainer where Self: UIViewController & DisposableContainer {

  func handle(panGesure: UIPanGestureRecognizer,
                      startTranslation: CGFloat,
                      range: ClosedRange<CGFloat>,
                      anchor: Anchor) {
    let yTranslation = anchor == .bottom ? -panGesure.translation(in: view).y : panGesure.translation(in: view).y
    let totalTranslation = startTranslation + yTranslation
    if sliderSheetHeight > range.upperBound {
      sliderSheetHeight = range.upperBound * (1 + log10(totalTranslation / range.upperBound))
    } else if self.sliderSheetHeight < range.lowerBound {
      let factor = 1.0 - (range.lowerBound - max(0.0, totalTranslation)) / range.upperBound
      sliderSheetHeight = range.lowerBound * factor
    } else {
      sliderSheetHeight = totalTranslation
    }
  }

  func animateView(to target: AnimationTarget,
                           with velocity: CGPoint,
                           in range: ClosedRange<CGFloat>) {
    let targetPoint: CGPoint
    switch target {
    case .start:
      targetPoint = CGPoint(x: 0.0, y: range.upperBound)
    case .end:
      targetPoint = CGPoint(x: 0.0, y: range.lowerBound)
    }

    func magnitude(vector: CGPoint) -> CGFloat {
      return sqrt(pow(vector.x, 2) + pow(vector.y, 2))
    }

    let totalDistance = magnitude(vector: targetPoint)
    let magVelocity = magnitude(vector: velocity)

    let animationDuration: TimeInterval = 0.44
    let springVelocity: CGFloat = magVelocity / totalDistance / CGFloat(animationDuration)

    UIView.animate(withDuration: animationDuration,
                   delay: 0,
                   usingSpringWithDamping: 0.9,
                   initialSpringVelocity: springVelocity,
                   options: .allowUserInteraction,
                   animations: { () -> Void in
                    self.sliderSheetHeight = targetPoint.y
                    self.view.layoutIfNeeded()
    }, completion: nil)
  }
}
