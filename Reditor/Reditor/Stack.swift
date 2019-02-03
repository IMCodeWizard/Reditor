//
//  Stack.swift
//  CustomControls
//
//  Created by Ninja on 15/10/2018.
//  Copyright © 2018 iOS Ninja. All rights reserved.
//

import Foundation


public struct Stack<T> {
    fileprivate var array = [T]()
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public var count: Int {
        return array.count
    }
    
    public mutating func push(_ element: T) {
        array.append(element)
    }
    
    public mutating func pop() -> T? {
        return array.popLast()
    }
    
    public var top: T? {
        return array.last
    }
    
    public mutating func clear() {
        array.removeAll()
    }
    
    public func rawArray() -> Array<T> {
        return array
    }
}

extension Stack: Sequence {
    public func makeIterator() -> AnyIterator<T> {
        var curr = self
        return AnyIterator {
            return curr.pop()
        }
    }
}
