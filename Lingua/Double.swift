//
//  Double.swift
//  Lingua
//
//  Created by David Warner on 11/25/16.
//  Copyright © 2016 davewarner. All rights reserved.
//

import Foundation

extension Double {

    var percentageString: String {
        return "\(truncate(places: 2) * 100)%"
    }

    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
