//
//  FaceDetector.swift
//  VideoFx
//
//  Created by liewli on 4/11/20.
//  Copyright © 2020 liewli. All rights reserved.
//

import Foundation
import Vision

class FaceDetector {
    typealias FaceFrameCallback = (CGRect?) -> Void

    private let callback: FaceFrameCallback

    init(callback: @escaping FaceFrameCallback) {
        self.callback = callback
    }

    func handle(buffer: CVPixelBuffer, orientation: CGImagePropertyOrientation) {
        let vnRequestOptions: [VNImageOption: Any] = [:]
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: buffer,
                                                        orientation: orientation,
                                                        options: vnRequestOptions)

        do {
            let request = VNDetectFaceRectanglesRequest { [weak self] request, err in
                self?.handleRequest(request: request, error: err)
            }

            try imageRequestHandler.perform([request])
        } catch {
            print(error)
        }
    }

    private func handleRequest(request: VNRequest, error _: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                let faces = request.results as? [VNFaceObservation] else {
                return
            }

            let frames = faces.map { $0.boundingBox }
                .sorted { $0.width * $0.height > $0.width * $1.height }
            self.callback(frames.first)
        }
    }
}
