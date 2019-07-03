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
    @IBOutlet private weak var shutterButtonAreaView: UIView!
    @IBOutlet private weak var shutterButtonView: UIView!
    @IBOutlet private weak var shutterButton: UIButton!
    @IBOutlet private weak var captureSessionView: UIView!

    private let session: AVCaptureSession
    private let output: AVCapturePhotoOutput = .init()
    private var capturePhotoSettings: AVCapturePhotoSettings {
        // Output用の出力設定を生成（今回は出力される映像の方を全てjpegにする設定のみ）
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        // フラッシュの設定
        settings.flashMode = .auto
        // 最高の解像度を返すにはDeviceのhighResolutionStillImageDimensionsを設定する必要あり
//        settings.isHighResolutionPhotoEnabled = true
        return settings
    }

    init(session: AVCaptureSession) {
        self.session = session
        super.init(nibName: String(describing: CameraViewController.self), bundle: .main)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        captureSessionView.backgroundColor = .red
        if setupSession() {
            setupCamera()
        } else {
            print("outputの追加に失敗")
        }
        setupShutterButton()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        session.stopRunning()
    }

    // MARK: - Action

    @IBAction func didTapShutterButton(_ sender: UIButton) {
        output.capturePhoto(with: capturePhotoSettings, delegate: self)
    }

    @objc private func takePhoto(sender: UIButton) {
        sender.isEnabled = false
        output.capturePhoto(with: capturePhotoSettings, delegate: self)
    }

    @objc private func shrinkShutterButton(sender: UIButton) {
        let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut, animations: { [weak self] in
            self?.shutterButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
        animator.startAnimation()
    }

    @objc private func restoreShutterButton(sender: UIButton) {
        let animator = UIViewPropertyAnimator(duration: 0.1, curve: .easeOut, animations: { [weak self] in
            self?.shutterButton.transform = .identity
        })
        animator.startAnimation()
    }

    // MARK: - Private

    private func setupShutterButton() {
        shutterButton.addTarget(self, action: #selector(shrinkShutterButton(sender:)), for: .touchDown)
        shutterButton.addTarget(self, action: #selector(restoreShutterButton(sender:)), for: [.touchDragOutside, .touchUpInside])
        shutterButton.addTarget(self, action: #selector(takePhoto(sender:)), for: .touchUpInside)
        roundCorner(views: [shutterButtonView, shutterButton])
        shutterButtonView.layer.borderColor = UIColor.white.cgColor
        shutterButtonView.layer.borderWidth = 6
        // カメラの上にViewを乗せたい時はレイヤーを上にする
        view.bringSubviewToFront(shutterButtonAreaView)
    }

    private func setupSession() -> Bool {
        // OutputがSessionに追加できるか
        guard session.canAddOutput(output) else {
            return false
        }
        session.addOutput(output)
        return true
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
        layer.frame = captureSessionView.frame
        // viewにlayerをadd
        captureSessionView.layer.addSublayer(layer)
    }

    private func roundCorner(views: [UIView]) {
        view.layoutIfNeeded()
        views.forEach {
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = $0.frame.width / 2
        }
    }

}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        shutterButton.isEnabled = true
        print(output)
    }
}
