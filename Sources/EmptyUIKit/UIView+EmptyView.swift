//
//  UIView+EmptyView.swift
//
//  Created by Sereivoan Yong on 4/30/21.
//

import UIKit

func class_exchangeInstanceMethodImplementations(_ klass: AnyClass, _ originalSelector: Selector, _ swizzledSelector: Selector) {
  let originalMethod = class_getInstanceMethod(klass, originalSelector).unsafelyUnwrapped
  let swizzledMethod = class_getInstanceMethod(klass, swizzledSelector).unsafelyUnwrapped
  let wasMethodAdded = class_addMethod(klass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
  if wasMethodAdded {
    class_replaceMethod(klass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
  } else {
    method_exchangeImplementations(originalMethod, swizzledMethod)
  }
}

extension UIView {

  private static var emptyViewKey: Void?
  public var emptyView: EmptyView? {
    get {
      return objc_getAssociatedObject(self, &Self.emptyViewKey) as? EmptyView
    }
    set {
      if let emptyView {
        emptyView.removeFromSuperview()
      }
      if let newValue {
        UICollectionView.swizzlingHandler
        UITableView.swizzlingHandler
        assert(newValue.superview == nil)
        newValue.translatesAutoresizingMaskIntoConstraints = false
        addSubview(newValue)

        NSLayoutConstraint.activate([
          newValue.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
          newValue.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor),
          newValue.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor),
          newValue.topAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.topAnchor)
        ])
      }
      objc_setAssociatedObject(self, &Self.emptyViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}

extension UICollectionView {

  fileprivate static let swizzlingHandler: Void = {
    let klass = UICollectionView.self
    class_exchangeInstanceMethodImplementations(klass, #selector(reloadData), #selector(_emptyuikit_reloadData))
    class_exchangeInstanceMethodImplementations(klass, #selector(performBatchUpdates(_:completion:)), #selector(_emptyuikit_performBatchUpdates(_:completion:)))
  }()

  @objc private func _emptyuikit_reloadData() {
    _emptyuikit_reloadData()
    reloadEmptyViewIfPossible()
  }

  @objc private func _emptyuikit_performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)?) {
    _emptyuikit_performBatchUpdates(updates, completion: completion)
    reloadEmptyViewIfPossible()
  }
}

extension UITableView {

  fileprivate static let swizzlingHandler: Void = {
    let klass = UITableView.self
    class_exchangeInstanceMethodImplementations(klass, #selector(reloadData), #selector(_emptyuikit_reloadData))
    class_exchangeInstanceMethodImplementations(klass, #selector(performBatchUpdates(_:completion:)), #selector(_emptyuikit_performBatchUpdates(_:completion:)))
    class_exchangeInstanceMethodImplementations(klass, #selector(endUpdates), #selector(_emptyuikit_endUpdates))
  }()

  @objc private func _emptyuikit_reloadData() {
    _emptyuikit_reloadData()
    reloadEmptyViewIfPossible()
  }

  @objc private func _emptyuikit_performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)?) {
    _emptyuikit_performBatchUpdates(updates, completion: completion)
    reloadEmptyViewIfPossible()
  }

  @objc private func _emptyuikit_endUpdates() {
    _emptyuikit_endUpdates()
    reloadEmptyViewIfPossible()
  }
}
