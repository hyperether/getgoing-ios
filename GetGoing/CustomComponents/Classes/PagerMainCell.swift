//
//  PagerMainCell.swift
//  GetGoing
//
//  Created by Milan Vidovic on 8/8/19.
//  Copyright © 2019 Milan Vidovic. All rights reserved.
//

import Foundation
import FSPagerView

class PagerMainCell : FSPagerViewCell {
    
    
    @IBOutlet weak var styleImageVIew: UIImageView!
    
    var styleName : String!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        self.contentView.layer.shadowColor = UIColor.black.cgColor
        self.contentView.layer.shadowRadius = 0
        self.contentView.layer.shadowOpacity = 0
        self.contentView.layer.shadowOffset = .zero
    }
    
}
