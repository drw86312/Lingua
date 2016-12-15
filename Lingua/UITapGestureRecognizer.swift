//
//  UITapGestureRecognizer.swift
//  Lingua
//
//  Created by David Warner on 12/10/16.
//  Copyright © 2016 davewarner. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

class ReactiveTapGesture: UITapGestureRecognizer {

    let bnd_tap = PublishSubject<UITapGestureRecognizer, NoError>()
    private let proxy: ReactiveTapGestureProxy

    init() {
        proxy = ReactiveTapGestureProxy(subject: bnd_tap)
        super.init(target: proxy, action: #selector(ReactiveTapGestureProxy.tapped(_:)))
    }

    deinit {
        print("Tap Gesture Deinit")
    }
}

class ReactiveTapGestureProxy: NSObject {

    private let bnd_tap: PublishSubject<UITapGestureRecognizer, NoError>

    init(subject: PublishSubject<UITapGestureRecognizer, NoError>) {
        self.bnd_tap = subject
    }

    internal func tapped(_ sender: UITapGestureRecognizer) {
        bnd_tap.next(sender)
    }
}
