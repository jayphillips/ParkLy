//
//  RoundButton.swift
//  Park.ly
//
//  Created by Jay Phillips on 2/15/21.
//

import UIKit

class RoundButton: UIButton {

    override func awakeFromNib() {
        //MARK: Corner Radius
        self.layer.cornerRadius = self.frame.height / 2
        
        //MARK: Shadow
        self.layer.shadowRadius = 20
        self.layer.shadowOpacity = 0.5
        self.layer.shadowColor = UIColor.black.cgColor
    }
}
