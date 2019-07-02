//
//  CameraViewController.swift
//  Camera-AVFoundation-Sample
//
//  Created by kawaharadai on 2019/07/03.
//  Copyright © 2019 kawaharadai. All rights reserved.
//

import AVFoundation
import UIKit

final class CameraViewController: UIViewController {

    private let session: AVCaptureSession

    init(session: AVCaptureSession) {
        self.session = session
        super.init(nibName: String(describing: CameraViewController.self), bundle: .main)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    private func setupCamera() {
        // 撮影スタート
        session.startRunning()

        // セッションからlayerを作る
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        // カメラViewの向きを縦に固定
        layer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        // layerの大きさを決める（画面の更新時には更新した方が良い）
        layer.frame = view.frame
        // viewにlayerをadd
        view.layer.addSublayer(layer)
    }

}
