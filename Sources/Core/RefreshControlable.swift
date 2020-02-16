//
//  RefreshControlable.swift
//  Nocturnal
//
//  Created by Sergei Mikhan on 2/16/20.
//

public protocol RefreshControlable {

  var refreshControl: UIRefreshControl? { get set }
}

extension UIScrollView: RefreshControlable {

  private enum Associated {
    static var refreshControl = "refreshControl"
  }

  public var refreshControl: UIRefreshControl? {
    get { return associated.value(for: &Associated.refreshControl) }
    set {
      if let oldRefreshControl = refreshControl {
        oldRefreshControl.removeFromSuperview()
      }
      if let newRefreshControl = newValue {
        addSubview(newRefreshControl)
      }
      associated.set(newValue, for: &Associated.refreshControl)
    }
  }
}
