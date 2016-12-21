//
//  TranslationScreenViewController.swift
//  Lingua
//
//  Created by David Warner on 11/28/16.
//  Copyright © 2016 davewarner. All rights reserved.
//

import UIKit
import Bond

class TranslationScreenViewController: UIViewController {


    @IBOutlet weak var confidenceLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModelBindings()
    }

    private func setupViewModelBindings() {

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == InterfaceConstants.Segue.translationScreenToListSegue),
            let vc = segue.destination as? TranslationListViewController {
            
        }
    }
}
