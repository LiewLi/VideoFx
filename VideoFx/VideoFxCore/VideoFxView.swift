//
//  VideoFxView.swift
//  VideoFx
//
//  Created by liewli on 4/11/20.
//  Copyright © 2020 liewli. All rights reserved.
//

import UIKit

class VideoFxView: CoreImageView {
    var source: CaptureSource?

    lazy var filter: Filter = {
        identity()
    }()

    lazy var coreImageView: CoreImageView = {
        CoreImageView()
    }()

    lazy var faceDetector: FaceDetector = {
        FaceDetector { [weak self] rect in
            guard let self = self else { return }
            var frame: CGRect?
            if let rect = rect {
                frame = self.transformedRect(rect: rect)
            }
            self.drawBounding(frame: frame)
            if let frame = frame {
                self.runOnProcessingQueueSync {
                    self.filter = overlay(image: UIImage(named: "overlay")!, rect: frame.normalized(width: self.frame.width, height: self.frame.height))
                }
            } else {
                self.runOnProcessingQueueSync {
                    self.filter = identity()
                }
            }
        }

    }()

    lazy var boundingLayer: CAShapeLayer = {
        let v = CAShapeLayer()
        v.borderWidth = 2.0
        v.borderColor = UIColor.orange.cgColor
        return v
    }()

    let queueKey = DispatchSpecificKey<Void>()

    lazy var processingQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "videofx.queue")
        queue.setSpecific(key: self.queueKey, value: ())
        return queue
    }()

    func runOnProcessingQueueSync(_ work: @escaping () -> Void) {
        if DispatchQueue.getSpecific(key: queueKey) != nil {
            work()
        } else {
            processingQueue.sync {
                work()
            }
        }
    }

    func drawBounding(frame: CGRect?) {
        if boundingLayer.superlayer != nil {
            boundingLayer.removeFromSuperlayer()
        }

        if let frame = frame {
            layer.addSublayer(boundingLayer)
            boundingLayer.frame = frame
        }
    }

    func start() {
        source?.running = false
        setup()
    }

    func stop() {
        source?.running = true
    }

    private func setup() {
        source = CaptureSource(position: .front) { [weak self] buffer, orientationTransform in
            guard let self = self else { return }
            guard let pixelBuffer = buffer.imageBuffer else { return }

            self.faceDetector.handle(buffer: pixelBuffer, orientation: orientationTransform)

            let input = CIImage(cvPixelBuffer: pixelBuffer)
                .oriented(orientationTransform)

            self.runOnProcessingQueueSync {
                let filteredImg = self.filter(input)
                DispatchQueue.main.async {
                    self.image = filteredImg
                }
            }
        }
        source?.running = true
    }

    private func transformedRect(rect: CGRect) -> CGRect {
        let transform = CGAffineTransform(scaleX: 1, y: -1)
            .translatedBy(x: 0, y: -frame.height)
        let translate = CGAffineTransform
            .identity
            .scaledBy(x: frame.width, y: frame.height)

        let frame = rect.applying(translate).applying(transform)
        return frame
    }
}
