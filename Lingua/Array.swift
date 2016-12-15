//
//  Array.swift
//  Lingua
//
//  Created by David Warner on 12/9/16.
//  Copyright © 2016 davewarner. All rights reserved.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {

    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
