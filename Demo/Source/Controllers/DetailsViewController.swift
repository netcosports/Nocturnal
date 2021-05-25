//
//  DetailsViewController.swift
//  Demo
//
//  Created by Sergei Mikhan on 10.03.21.
//  Copyright © 2021 NetcoSports. All rights reserved.
//

import Nocturnal

import Astrolabe

class DetailsViewController: ViewController, NavigationBarTransparencyHost, Lifecycle, DisposableContainer, Scrolling {
  let collectionView = CollectionView<CollectionViewSource>()

  override var backgroundColor: UIColor? {
    return .blue
  }

  var scrollView: UIScrollView {
    collectionView
  }

  var transparentNavigationBar: TransparentNavigationBar? {
    return (self.navigationController as? NavigationController)?.customNavigationBar
  }

  var preferredNavigationBarTransparency: NavigationBarTransparencySupport {
    .enabled
  }

  override var navigationBarHeight: CGFloat {
    return 120.0
  }

  override var trailingViews: [BarItemViewable] {
    return []
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    titleLabel.text = "DETAILS"

    setupTransparencyHost()
    connectNavBarVisibilityToScrollView()

    view.backgroundColor = .white
    view.addSubview(collectionView)

    let cells: [Cellable] = [
      CollectionCell<TestCell>(data: "Red"),
      CollectionCell<TestCell>(data: "Blue"),
      CollectionCell<TestCell>(data: "Green"),
      CollectionCell<TestCell>(data: "Red"),
      CollectionCell<TestCell>(data: "Blue"),
      CollectionCell<TestCell>(data: "Green"),
      CollectionCell<TestCell>(data: "Red"),
      CollectionCell<TestCell>(data: "Blue"),
      CollectionCell<TestCell>(data: "Green"),
      CollectionCell<TestCell>(data: "Red"),
      CollectionCell<TestCell>(data: "Blue"),
      CollectionCell<TestCell>(data: "Green"),
      CollectionCell<TestCell>(data: "Red"),
      CollectionCell<TestCell>(data: "Blue"),
      CollectionCell<TestCell>(data: "Green"),
      CollectionCell<TestCell>(data: "Red"),
      CollectionCell<TestCell>(data: "Blue"),
      CollectionCell<TestCell>(data: "Green"),
      CollectionCell<TestCell>(data: "Red"),
      CollectionCell<TestCell>(data: "Blue"),
      CollectionCell<TestCell>(data: "Green"),
      CollectionCell<TestCell>(data: "Red"),
      CollectionCell<TestCell>(data: "Blue"),
      CollectionCell<TestCell>(data: "Green"),
      CollectionCell<TestCell>(data: "Red"),
      CollectionCell<TestCell>(data: "Blue"),
      CollectionCell<TestCell>(data: "Green")
    ]

    collectionView.source.sections = [Section(cells: cells)]
    collectionView.reloadData()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    collectionView.pin.all()
  }
}

