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
    @IBOutlet private weak var shutterButton: UIButton!

    private let session: AVCaptureSession
    private let output: AVCapturePhotoOutput
    private var capturePhotoSettings: AVCapturePhotoSettings {
        // Output用の出力設定を生成（今回は出力される映像の方を全てjpegにする設定のみ）
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        // フラッシュの設定
        settings.flashMode = .auto
        // 最高の解像度を返すにはDeviceのhighResolutionStillImageDimensionsを設定する必要あり
//        settings.isHighResolutionPhotoEnabled = true
        return settings
    }

    init(session: AVCaptureSession, output: AVCapturePhotoOutput) {
        self.session = session
        self.output = output
        super.init(nibName: String(describing: CameraViewController.self), bundle: .main)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        // カメラの上にViewを乗せたい時はレイヤーを上にする
        view.bringSubviewToFront(shutterButton)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        session.stopRunning()
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

    @IBAction func didTapShutterButton(_ sender: UIButton) {
        output.capturePhoto(with: capturePhotoSettings, delegate: self)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print(output)
    }


}
