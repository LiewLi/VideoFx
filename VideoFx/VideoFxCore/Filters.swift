//
//  Filters.swift
//  VideoFx
//
//  Created by liewli on 4/11/20.
//  Copyright © 2020 liewli. All rights reserved.
//

import CoreImage
import UIKit

typealias Filter = (CIImage) -> CIImage

func identity() -> Filter {
    return { img in
        img
    }
}

func blur(radius: Int) -> Filter {
    return { img in
        let parameters: [String: Any] = [kCIInputRadiusKey: radius,
                                         kCIInputImageKey: img]
        let filter = CIFilter(name: "CIGaussianBlur", parameters: parameters)!
        return filter.outputImage!
    }
}

func pixelate(scale: Float) -> Filter {
    return { img in
        let parameters: [String: Any] = [kCIInputScaleKey: scale, kCIInputImageKey: img]
        let filter = CIFilter(name: "CIPixellate", parameters: parameters)!
        return filter.outputImage!
    }
}

func overlay(overlayImg: CIImage, rect: CGRect) -> Filter {
    let n_x = clamp(val: rect.origin.x)
    let n_y = clamp(val: 1 - rect.origin.y)
    let n_w = clamp(val: rect.width)
    let n_h = clamp(val: rect.height)

    return { img in

        let scaleX = img.extent.width * n_w / overlayImg.extent.width
        let scaleY = img.extent.height * n_h / overlayImg.extent.height

        let over = overlayImg.transformed(by:
            CGAffineTransform(translationX: 0,
                              y: -overlayImg.extent.height)
                .translatedBy(x: n_x * img.extent.width, y: n_y * img.extent.height)
                .scaledBy(x: scaleX, y: scaleY))

        let parameters: [String: Any] = [kCIInputBackgroundImageKey: img,
                                         kCIInputImageKey: over]
        let filter = CIFilter(name: "CISourceOverCompositing", parameters: parameters)!
        return filter.outputImage!
    }
}

func overlay(image: UIImage, rect: CGRect) -> Filter {
    let ciimg = CIImage(image: image)!
    return overlay(overlayImg: ciimg, rect: rect)
}

precedencegroup pipePrecedence { associativity: left }

infix operator >>|: pipePrecedence

func >>| (lhs: @escaping Filter, rhs: @escaping Filter) -> Filter {
    return { img in
        rhs(lhs(img))
    }
}
