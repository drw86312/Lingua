//
//  MutableObservable2DArray.swift
//  Lingua
//
//  Created by David Warner on 12/9/16.
//  Copyright © 2016 davewarner. All rights reserved.
//

import Foundation
import Bond

extension MutableObservable2DArray {

    func removeRowsIn(sectionIndex: Int) {
        guard let section = sections[safe: sectionIndex] else { return }
        section
            .items
            .enumerated()
            .map { IndexPath(row: $0.0, section: sectionIndex) }
            .forEach { removeItem(at: $0) }
    }
}
