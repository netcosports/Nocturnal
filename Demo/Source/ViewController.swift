//
//  ViewController.swift
//  Demo
//
//  Created by Sergei Mikhan on 9.03.21.
//  Copyright © 2021 NetcoSports. All rights reserved.
//


import Nocturnal

import RxSwift
import RxCocoa

open class ViewController: BaseViewController, NavigationBarHostable {

  open override func viewDidLoad() {
    super.viewDidLoad()
    additionalSafeAreaInsets = .init(top: navigationBarHeight, left: 0.0, bottom: 0.0, right: 0.0)

    back.rx.tap.subscribe(onNext: { [weak self] in
      self?.navigationController?.popViewController(animated: true)
    }).disposed(by: disposeBag)

    menu.rx.tap.subscribe(onNext: { [weak self] in
      self?.navigationController?.popViewController(animated: true)
    }).disposed(by: disposeBag)
  }

  let back: UIButton = {
    let back = UIButton()
    back.setTitleColor(.black, for: .normal)
    back.setTitle("BACK", for: .normal)
    back.backgroundColor = .orange
    return back
  }()

  let menu: UIButton = {
    let back = UIButton()
    back.setTitleColor(.black, for: .normal)
    back.setTitle("MENU", for: .normal)
    back.backgroundColor = .orange
    return back
  }()

  let test: UILabel = {
    let test = UILabel()
    test.textColor = .black
    test.textAlignment = .center
    test.text = "TEST"
    test.backgroundColor = .orange
    return test
  }()

  let titleLabel: UILabel = {
    let test = UILabel()
    test.textColor = .black
    test.textAlignment = .center
    test.text = "TITLE"
    test.backgroundColor = .orange
    return test
  }()

  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    currentNavigationItem = NavigationItem(
      height: navigationBarHeight,
      backgroundColor: backgroundColor,
      titleView: titleView,
      leadingViews: leadingViews,
      trailingViews: trailingViews
    )
  }

  private var currentNavigationItem: NavigationItemable?
  open var customNavigationItem: NavigationItemable? {
    currentNavigationItem
  }

  open var navigationBarHeight: CGFloat {
    return 80.0
  }

  open var backgroundColor: UIColor? {
    .red
  }

  open var titleView: BarItemViewable? {
    return BarItemView(view: titleLabel, width: 120)
  }

  open var leadingViews: [BarItemViewable] {
    if (self.navigationController?.viewControllers.count ?? 0) > 1 {
      return [
        BarItemView(view: back, width: 120)
      ]
    } else {
      return [
        BarItemView(view: menu, width: 120)
      ]
    }
  }

  open var trailingViews: [BarItemViewable] {
    return [
      BarItemView(view: test, width: 120)
    ]
  }
}
