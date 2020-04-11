//
//  utils.swift
//  VideoFx
//
//  Created by liewli on 4/11/20.
//  Copyright © 2020 liewli. All rights reserved.
//

import UIKit

func clamp(val: CGFloat, _ minV: CGFloat = 0, _ maxV: CGFloat = 1.0) -> CGFloat {
    return min(max(minV, val), maxV)
}

extension CGRect {
    func normalized(width: CGFloat, height: CGFloat) -> CGRect {
        return CGRect(x: origin.x / width, y: origin.y / height, width: self.width / width, height: self.height / height)
    }
}
