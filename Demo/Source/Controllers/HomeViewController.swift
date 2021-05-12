//
//  HomeViewController.swift
//  Demo
//
//  Created by Sergei Mikhan on 7.03.21.
//  Copyright © 2021 NetcoSports. All rights reserved.
//

import UIKit
import Astrolabe

import Nocturnal

import PinLayout

class TestCell: CollectionViewCell, Reusable {

  typealias Data = String

  private let label = UILabel()

  override func setup() {
    super.setup()

    contentView.addSubview(label)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    label.pin.sizeToFit().center()
  }

  func setup(with data: Data) {
    label.text = data
  }

  static func size(for data: Data, containerSize: CGSize) -> CGSize {
    return CGSize(width: containerSize.width, height: 66.0)
  }
}

class HomeViewController: ViewController, NavigationBarTransparencyHost, DisposableContainer, Scrolling {
  let collectionView = CollectionView<CollectionViewSource>()

  var scrollView: UIScrollView {
    collectionView
  }

  var transparentNavigationBar: TransparentNavigationBar? {
    return (self.navigationController as? NavigationController)?.customNavigationBar
  }

  var preferredNavigationBarTransparency: NavigationBarTransparencySupport {
    .enabled
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    titleLabel.text = "HOME"

    setupTransparencyHost()
    connectNavBarVisibilityToScrollView()

    view.backgroundColor = .white
    view.addSubview(collectionView)

    let closure: ClickClosure? = { [weak self] in
      self?.navigationController?.pushViewController(DetailsViewController(), animated: true)
    }

    let cells: [Cellable] = [
      CollectionCell<TestCell>(data: "Red", click: closure),
      CollectionCell<TestCell>(data: "Blue", click: closure),
      CollectionCell<TestCell>(data: "Green", click: closure),
      CollectionCell<TestCell>(data: "Red", click: closure),
      CollectionCell<TestCell>(data: "Blue", click: closure),
      CollectionCell<TestCell>(data: "Green", click: closure),
      CollectionCell<TestCell>(data: "Red", click: closure),
      CollectionCell<TestCell>(data: "Blue", click: closure),
      CollectionCell<TestCell>(data: "Green", click: closure),
      CollectionCell<TestCell>(data: "Red", click: closure),
      CollectionCell<TestCell>(data: "Blue", click: closure),
      CollectionCell<TestCell>(data: "Green", click: closure),
      CollectionCell<TestCell>(data: "Red", click: closure),
      CollectionCell<TestCell>(data: "Blue", click: closure),
      CollectionCell<TestCell>(data: "Green", click: closure),
      CollectionCell<TestCell>(data: "Red", click: closure),
      CollectionCell<TestCell>(data: "Blue", click: closure),
      CollectionCell<TestCell>(data: "Green", click: closure),
      CollectionCell<TestCell>(data: "Red", click: closure),
      CollectionCell<TestCell>(data: "Blue", click: closure),
      CollectionCell<TestCell>(data: "Green", click: closure),
      CollectionCell<TestCell>(data: "Red", click: closure),
      CollectionCell<TestCell>(data: "Blue", click: closure),
      CollectionCell<TestCell>(data: "Green", click: closure),
      CollectionCell<TestCell>(data: "Red", click: closure),
      CollectionCell<TestCell>(data: "Blue", click: closure),
      CollectionCell<TestCell>(data: "Green", click: closure)
    ]

    collectionView.source.sections = [Section(cells: cells)]
    collectionView.reloadData()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    collectionView.pin.all()
  }
}
