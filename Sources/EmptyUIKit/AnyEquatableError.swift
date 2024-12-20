//
//  AnyEquatableError.swift
//
//  Created by Sereivoan Yong on 5/1/21.
//

#if canImport(Foundation)

import Foundation

@usableFromInline
struct AnyEquatableError {

  let error: Error
}

extension AnyEquatableError: Equatable {

  @usableFromInline
  static func == (lhs: AnyEquatableError, rhs: AnyEquatableError) -> Bool {
    // See: https://kandelvijaya.com/2018/04/21/blog_equalityonerror/
    if String(reflecting: lhs.error) == String(reflecting: rhs.error) {
      return lhs.error as NSError == rhs.error as NSError
    } else {
      return false
    }
  }
}

#endif
