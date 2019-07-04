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

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if setupSession() {
            setupCamera()
        } else {
            print("outputの追加に失敗")
        }
        setupComponent()
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
        output.capturePhoto(with: self.capturePhotoSettings, delegate: self)
    }

    @objc private func shrinkShutterButton(sender: UIButton) {
        let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut, animations: { [weak self] in
            self?.shutterButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
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

    private func setupComponent() {
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
        let layer = AVCaptureVideoPreviewLayer(session: self.session)
        layer.videoGravity = .resizeAspectFill
        // カメラViewの向きを縦に固定
        layer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        // layerの大きさを決める（画面の更新時には更新した方が良い、sessionは画面一杯なので、viewのframeにする）
        layer.frame = self.captureSessionView.frame
        // viewにlayerをadd
        self.captureSessionView.layer.addSublayer(layer)

        guard !session.isRunning else { return }
        
        session.startRunning()
    }

    private func roundCorner(views: [UIView]) {
        views.forEach {
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = $0.frame.width / 2
        }
    }

}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

        if let error = error {
            print("撮影データ取得処理でエラー発生")
            print(error.localizedDescription)
            return
        }

        if let photoData = photo.fileDataRepresentation(), let photoImage = UIImage(data: photoData) {
            let imageView = UIImageView(image: photoImage)
            imageView.frame = self.captureSessionView.frame
            captureSessionView.addSubview(imageView)
            session.stopRunning()
        } else if let screenShotView = captureSessionView.snapshotView(afterScreenUpdates: true),
            let photoData = screenShotView.image.jpegData(compressionQuality: 1.0) {
            // スクショ撮影 → jpegImageに変換 → Dataに変換 が成功したらここに入る
            captureSessionView.addSubview(screenShotView)
            session.stopRunning()
        } else {
            print("写真 and スクショ取得失敗")
            shutterButton.isEnabled = true
        }
    }
}

// MARK: - UIView

private extension UIView {
    // UIImageへの変換
    var image: UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }

    // subViewの全削除
    func removeSubView() {
        subviews.forEach {
            $0.removeFromSuperview()
        }
    }
}
