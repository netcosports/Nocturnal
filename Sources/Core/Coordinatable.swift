import RxSwift

public protocol Parentable: class {

  typealias Children = [UUID: Any]
  var identifier: UUID { get }
  var childCoordinators: Children { get set }
}

public protocol Startable {

  associatedtype ResultType
  func start() -> Observable<ResultType>
}

extension Parentable {

  func store<T: Parentable>(coordinator: T) {
    childCoordinators[coordinator.identifier] = coordinator
  }

  func free<T: Parentable>(coordinator: T) {
    childCoordinators[coordinator.identifier] = nil
  }
}

public protocol Coordinatable {

  func coordinate<T: Startable & Parentable>(to coordinator: T) -> Observable<T.ResultType>
}

extension Coordinatable where Self: Parentable {

  public func coordinate<T: Startable & Parentable>(to coordinator: T) -> Observable<T.ResultType> {
    store(coordinator: coordinator)
    return coordinator.start()
      .do(onCompleted: { [weak self] in
        self?.free(coordinator: coordinator)
      })
  }
}

public typealias Coordinator = Coordinatable & Startable & Parentable

private enum Associated {
  static var identifier = "identifier"
  static var childCoordinators = "childCoordinators"
}

public extension Parentable {

  var identifier: UUID {
    if let identifier = objc_getAssociatedObject(self, &Associated.identifier) as? UUID {
      return identifier
    }
    let identifier = UUID()
    objc_setAssociatedObject(self,
                             &Associated.identifier,
                             identifier,
                             .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return identifier
  }

  var childCoordinators: [UUID: Any] {
    get {
      if let children = objc_getAssociatedObject(self, &Associated.childCoordinators) as? Children {
        return children
      }
      return Children()
    }

    set {
      objc_setAssociatedObject(self,
                               &Associated.childCoordinators,
                               newValue,
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}
