//
//  LanguageSectionHeader.swift
//  Lingua
//
//  Created by David Warner on 12/10/16.
//  Copyright © 2016 davewarner. All rights reserved.
//

import UIKit

class LanguageSectionHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var backingView: UIView!

    override func prepareForReuse() {
        super.prepareForReuse()
        leftLabel.text = nil
        rightLabel.text = nil
    }
}
