//
//  SectionableViewModel.swift
//  CoreUI
//
//  Created by Sergei Mikhan on 12/27/19.
//

import Astrolabe
import Sundial

import RxSwift
import RxCocoa

public protocol SectionsLoadable: AnyObject {
  var source: EventDrivenLoaderSource? { get set }
  var autoscrollObserver: AnyObserver<AutoScrollTarget>? { get set }
  func loadAndMergeSections(from intent: LoaderIntent) -> Observable<LoaderResultEvent>
}

public protocol SectionableViewModel: SectionsLoadable {

  var sections: [Sectionable] { get set }
  func load(for intent: LoaderIntent) -> Observable<LoaderResultEvent>
}

public protocol Inputable {

  associatedtype Input
  var input: AnyObserver<Input> { get }
}

public protocol Outputable {

  associatedtype Out
  var output: Observable<Out> { get }
}

public extension Outputable where Out == Void {

  var output: Observable<Out> {
    return .never()
  }
}

public extension Inputable where Input == Void {

  var input: AnyObserver <Input> {
    return PublishSubject<Input>().asObserver()
  }
}

public extension SectionableViewModel {

  func loadAndMergeSections(from intent: LoaderIntent) -> Observable<LoaderResultEvent> {
    return load(for: intent)
        .catchError { error in return .just(.failed(error: error)) }
        .concat(Observable.just(.completed(intent: intent)))
        .map { (intent, $0) }
        .observeOn(MainScheduler.instance).map { [weak self] intent, results -> LoaderResultEvent in
          guard let self = self else { return .completed(intent: intent) }
          switch results {
          case .force(let sections, let context):
            let mergeResult = self.sections.merge(items: sections, for: intent)
            guard mergeResult?.status != .equalWithCurrent else {
              return .completed(intent: intent)
            }
            self.sections = mergeResult?.items ?? []
            return .force(sections: self.sections, context: context)
          default: return results
      }
    }
  }
}

public extension DisposableBindable where Self: BindableView & Lifecycle {

  func bind(sectionableViewModel: SectionsLoadable, with bindDisposeBag: DisposeBag, stateClosure: ((Astrolabe.LoaderState) -> (Bool))? = nil) {
    sectionableViewModel.autoscrollObserver = autoScrollSubject.asObserver()
    sectionableViewModel.source = source

    source.intentObservable.flatMapLatest { intent in
      return sectionableViewModel.loadAndMergeSections(from: intent)
    }.bind(to: source.sectionsObserver).disposed(by: bindDisposeBag)

    visibility
      .map { InputControlEvent.visibilityChanged(visible: $0) }
      .bind(to: source.controlObserver)
      .disposed(by: bindDisposeBag)

    pullToRefreshSubject
      .map { InputControlEvent.pullToRefresh }
      .bind(to: source.controlObserver)
      .disposed(by: bindDisposeBag)

    source.stateObservable.map { state -> Bool in
      switch state {
      case .error, .empty: return true
      default: return false
      }
    }.bind(to: emptyViewSubject).disposed(by: bindDisposeBag)

    source.stateObservable.flatMap { state -> Observable<Error?> in
      switch state {
      case .error(let error):
        return .just(error)
      default:
        return .empty()
      }
    }.bind(to: errorSubject).disposed(by: bindDisposeBag)

    let loading = source.stateObservable.map { state -> Bool in
      if let closure = stateClosure {
        return closure(state)
      } else {
        switch state {
        case .loading: return true
        default: return false
        }
      }
    }
    loading.bind(to: loaderViewSubject).disposed(by: bindDisposeBag)
    loading.bind(to: refreshViewSubject).disposed(by: bindDisposeBag)
  }
}
