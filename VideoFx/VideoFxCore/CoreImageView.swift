//
//  CoreImageView.swift
//  VideoFx
//
//  Created by liewli on 4/10/20.
//  Copyright © 2020 liewli. All rights reserved.
//

import Foundation
import MetalKit
import UIKit

class CoreImageView: MTKView {
    let coreImageContex: CIContext

    let commandQueue: MTLCommandQueue

    var image: CIImage? {
        didSet {
            draw()
        }
    }

    override init(frame frameRect: CGRect, device: MTLDevice?) {
        guard let device = device else {
            fatalError("metal device not avaiable")
        }
        commandQueue = device.makeCommandQueue()!
        coreImageContex = CIContext(mtlDevice: device, options: [.useSoftwareRenderer: false])
        super.init(frame: frameRect, device: device)

        framebufferOnly = false
        enableSetNeedsDisplay = false
        isPaused = true
        clearColor = MTLClearColorMake(0, 0, 0, 0)
    }

    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_: CGRect) {
        guard let img = image else { return }
        let scale = window?.screen.scale ?? 1.0
        let destRect = bounds.applying(CGAffineTransform(scaleX: scale, y: scale))

        let drawScale = max(destRect.width / img.extent.width, destRect.height / img.extent.height)

        let commandBuffer = commandQueue.makeCommandBuffer()

        guard let texture = currentDrawable?.texture else {
            return
        }
        let colorSpace = img.colorSpace ?? CGColorSpaceCreateDeviceRGB()
        coreImageContex.render(img.transformed(by: CGAffineTransform(scaleX: drawScale, y: drawScale)), to: texture, commandBuffer: commandBuffer, bounds: destRect, colorSpace: colorSpace)
        commandBuffer?.present(currentDrawable!)
        commandBuffer?.commit()
    }
}
