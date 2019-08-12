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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
}
