//
//  With.swift
//  Candy Crush
//
//  Created by Dwayne Reinaldy on 5/6/22.
//

import Foundation

func with<Value>(_ value: Value, update: (inout Value) throws -> Void) rethrows -> Value {
    var copy = value
    try update(&copy)
    return copy
}
