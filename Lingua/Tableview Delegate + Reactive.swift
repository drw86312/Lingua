//
//  Tableview Delegate + Reactive.swift
//  Lingua
//
//  Created by David Warner on 11/27/16.
//  Copyright © 2016 davewarner. All rights reserved.
//

import Bond
import UIKit
import ReactiveKit

extension UITableView {
    
    var selectedRow: Signal<IndexPath, NoError> {
        return bnd_delegate
            .signal(for: #selector(UITableViewDelegate.tableView(_:didSelectRowAt:))) { (subject: PublishSubject<NSIndexPath, NoError>, _: UITableView, indexPath: NSIndexPath) in
                subject.next(indexPath)
            }
            .map { IndexPath(row: $0.row, section: $0.section) }
    }

    var didScroll: Signal<Void, NoError> {
        return bnd_delegate
            .signal(for: #selector(UIScrollViewDelegate.scrollViewWillBeginDragging(_:))) { (subject: PublishSubject<Void, NoError>, _: UIScrollView) in
                subject.next(())
            }
    }
}
