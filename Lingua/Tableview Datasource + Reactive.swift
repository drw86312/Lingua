//
//  Tableview Datasource + Reactive.swift
//  Lingua
//
//  Created by David Warner on 11/27/16.
//  Copyright © 2016 davewarner. All rights reserved.
//

import Bond
import UIKit
import ReactiveKit

//public protocol DataSourceProtocol {
//    func numberOfSections() -> Int
//    func numberOfItems(inSection section: Int) -> Int
//}
//
//public struct DataSourceEvent<DataSource: DataSourceProtocol>: DataSourceEventProtocol {
//    public let kind: DataSourceEventKind
//    public let dataSource: DataSource
//}
//
//public enum DataSourceEventKind {
//    case reload
//
//    case insertRows([IndexPath])
//    case deleteRows([IndexPath])
//    case reloadRows([IndexPath])
//    case moveRow(IndexPath, IndexPath)
//
//    case insertSections(IndexSet)
//    case deleteSections(IndexSet)
//    case reloadSections(IndexSet)
//    case moveSection(Int, Int)
//
//    case beginUpdates
//    case endUpdates
//}
