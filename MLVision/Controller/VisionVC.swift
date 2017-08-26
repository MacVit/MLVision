//
//  VisionVC.swift
//  MLVision
//
//  Created by Vitaliy Maksymlyuk on 8/25/17.
//  Copyright © 2017 Vitaliy Maksymlyuk. All rights reserved.
//

import UIKit

class VisionVC: UIViewController {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var roundedLblView: RoundedShadowView!
    @IBOutlet weak var identLbl: UILabel!
    @IBOutlet weak var confidenceLbl: UILabel!
    @IBOutlet weak var captureImageView: RoundedShadowImageView!
    @IBOutlet weak var flashBtn: RoundedShadowButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

