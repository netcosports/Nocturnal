//
//  BaseViewController.swift
//  Demo
//
//  Created by Sergei Mikhan on 7.03.21.
//  Copyright © 2021 NetcoSports. All rights reserved.
//

import Nocturnal

import RxSwift
import RxCocoa

open class BaseViewController: UIViewController {
  public let disposeBag = DisposeBag()
  open var backButtonColor: UIColor {
    return UIColor.white
  }

  public init() {
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Overrides
  open override var prefersStatusBarHidden: Bool {
    return false
  }

  open override var shouldAutorotate: Bool {
    return true
  }

  open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }

  open override var hidesBottomBarWhenPushed: Bool {
    get { return false }
    set { super.hidesBottomBarWhenPushed = newValue }
  }

  open override var prefersHomeIndicatorAutoHidden: Bool {
    return true
  }

  open override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  // MARK: - Lifecycle
  open override func loadView() {
    super.loadView()
  }

  open override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.black
  }

  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
}

