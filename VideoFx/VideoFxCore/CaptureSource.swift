//
//  CaptureSource.swift
//  VideoFx
//
//  Created by liewli on 4/10/20.
//  Copyright © 2020 liewli. All rights reserved.
//

import AVFoundation
import Foundation

typealias CaptureCallback = (CMSampleBuffer, CGImagePropertyOrientation) -> Void

class CaptureSource {
    private let captureSession: AVCaptureSession
    private let captureDelegate: CaptureDelegate

    var running: Bool = false {
        didSet {
            if running {
                captureSession.startRunning()
            } else {
                captureSession.stopRunning()
            }
        }
    }

    init?(position: AVCaptureDevice.Position, callback: @escaping CaptureCallback) {
        captureSession = AVCaptureSession()
        guard let device = position.device,
            let deviceInput = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(deviceInput)
        else {
            return nil
        }

        captureSession.addInput(deviceInput)
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.alwaysDiscardsLateVideoFrames = true
        captureDelegate = CaptureDelegate(callback: { buffer in
            callback(buffer, position.orientationTransform)
        })
        dataOutput.setSampleBufferDelegate(captureDelegate, queue: DispatchQueue.main)
        captureSession.addOutput(dataOutput)
        captureSession.commitConfiguration()
    }
}

private class CaptureDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let callback: (CMSampleBuffer) -> Void
    init(callback: @escaping (CMSampleBuffer) -> Void) {
        self.callback = callback
    }

    func captureOutput(_: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from _: AVCaptureConnection) {
        callback(sampleBuffer)
    }
}

extension AVCaptureDevice.Position {
    var device: AVCaptureDevice? {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: self)
    }

    var orientationTransform: CGImagePropertyOrientation {
        switch self {
        case .front:
            return .leftMirrored
        case .back:
            return .right
        default:
            return .up
        }
    }
}
