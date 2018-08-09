//
//  WelcomeController.swift
//  ARChartsSampleApp
//
//  Created by Arend Oppewal on 9/8/18.
//  Copyright © 2018 Boris Emorine. All rights reserved.
//

import UIKit

class WelcomeController: UIViewController
{
    @IBAction func tapStartButton(_ sender: UIButton) {
        performSegue(withIdentifier: "WelcomeSegue", sender: nil)
    }
}
