//
//  ViewController.swift
//  VideoFx
//
//  Created by liewli on 4/10/20.
//  Copyright © 2020 liewli. All rights reserved.
//

import MetalKit
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (view as? VideoFxView)?.start()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        (view as? VideoFxView)?.stop()
    }

    override func loadView() {
        let device = MTLCreateSystemDefaultDevice()
        view = VideoFxView(frame: .zero, device: device)
    }
}
