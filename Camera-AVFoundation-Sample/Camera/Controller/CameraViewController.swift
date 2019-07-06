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
    @IBOutlet private weak var closeButtonView: UIView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var reshootButtonView: UIView!
    @IBOutlet private weak var reshootButton: UIButton!
    @IBOutlet private weak var captureSessionView: UIView!

    private let session: AVCaptureSession
    private let previewLayer: AVCaptureVideoPreviewLayer
    private let output: AVCapturePhotoOutput = .init()
    private let sessionQueue = DispatchQueue(label: "sessionQueue", attributes: .concurrent)
    private var capturePhotoSettings: AVCapturePhotoSettings {
        // Output用の出力設定を生成（今回は出力される映像の方を全てjpegにする設定のみ）
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        // フラッシュの設定
        settings.flashMode = .auto

        return settings
    }

    init(session: AVCaptureSession) {
        self.session = session
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
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
        if session.canAddOutput(output) {
            session.addOutput(output)
            setupCamera()
            setupComponent()
        } else {
            print("set error View")
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = captureSessionView.frame
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopSession()
    }

    // MARK: - Action

    @objc private func takePhoto(sender: UIButton) {
        sender.isEnabled = false
        closeButton.isEnabled = true
        reshootButton.isEnabled = true
        output.capturePhoto(with: self.capturePhotoSettings, delegate: self)
    }

    @objc private func shrinkButton(sender: UIButton) {
        trasformAnimation(duration: 0.2) {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }

    @objc private func restoreButton(sender: UIButton) {
        trasformAnimation(duration: 0.1) {
            sender.transform = .identity
        }
    }

    @objc private func reshoot(sender: UIButton) {
        sender.isEnabled = false
        shutterButton.isEnabled = true
        captureSessionView.removeSubView()
        if session.isRunning {
            updateButtonsStatus(isShooting: true, duration: 0.3)
        } else {
            startSession { [weak self] in
                self?.updateButtonsStatus(isShooting: true, duration: 0.3)
            }
        }
    }

    @objc private func close(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    private func trasformAnimation(duration: TimeInterval, _ completion: @escaping () -> ()) {
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut, animations: {
            completion()
        })
        animator.startAnimation()
    }

    // MARK: - Private

    private func setupComponent() {
        addShrinkAction(buttons: [shutterButton, closeButton, reshootButton])
        addRestoreAction(buttons: [shutterButton, closeButton, reshootButton])
        shutterButton.addTarget(self, action: #selector(takePhoto(sender:)), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(close(sender:)), for: .touchUpInside)
        reshootButton.addTarget(self, action: #selector(reshoot(sender:)), for: .touchUpInside)
        roundCorner(views: [shutterButtonView, shutterButton,
                            closeButtonView, closeButton,
                            reshootButtonView, reshootButton])
        addBorderLine(views: [(shutterButtonView, .white),
                              (closeButtonView, closeButton.backgroundColor!),
                              (reshootButtonView, reshootButton.backgroundColor!)])
        updateButtonsStatus(isShooting: true, duration: 0.0)
    }

    private func setupCamera() {
        // 表示方式を定義（出力用のimageViewのcontentModeに合わせた方が良い）
        previewLayer.videoGravity = .resizeAspectFill
        // カメラViewの向きを縦に固定
        previewLayer.connection?.videoOrientation = .portrait
        captureSessionView.layer.addSublayer(previewLayer)

        // 既に開始してたならreturn
        guard !session.isRunning else { return }
        
        startSession {
            DispatchQueue.main.async { [weak self] in
                self?.shutterButton.isEnabled = true
            }
        }
    }

    private func updateButtonsStatus(isShooting: Bool, duration: TimeInterval) {
        let shutterButtonViewTransform = isShooting ? .identity : CGAffineTransform(scaleX: 0.1, y: 0.1)
        let otherButtonViewTransform = isShooting ? CGAffineTransform(scaleX: 0.1, y: 0.1) : .identity
        DispatchQueue.main.async { [weak self] in
            self?.shutterButtonView.isHidden = !isShooting
            self?.closeButtonView.isHidden = isShooting
            self?.reshootButtonView.isHidden = isShooting
            self?.trasformAnimation(duration: duration) {
                self?.shutterButtonView.transform = shutterButtonViewTransform
                self?.closeButtonView.transform = otherButtonViewTransform
                self?.reshootButtonView.transform = otherButtonViewTransform
            }
        }
    }

    private func startSession(_ completion: @escaping () -> ()) {
        sessionQueue.async { [weak self] in
            self?.session.startRunning()
            completion()
        }
    }

    private func stopSession() {
        sessionQueue.async { [weak self] in
            self?.session.stopRunning()
        }
    }

    private func roundCorner(views: [UIView]) {
        views.forEach {
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = $0.frame.width / 2
        }
    }

    private func addShrinkAction(buttons: [UIButton]) {
        buttons.forEach {
            $0.addTarget(self, action: #selector(shrinkButton(sender:)), for: .touchDown)
        }
    }

    private func addRestoreAction(buttons: [UIButton]) {
        buttons.forEach {
            $0.addTarget(self, action: #selector(restoreButton(sender:)), for: [.touchDragOutside, .touchUpInside])
        }
    }

    private func addBorderLine(views: [(view: UIView, color: UIColor)]) {
        views.forEach {
            $0.view.layer.borderColor = $0.color.cgColor
            $0.view.layer.borderWidth = 6
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
            imageView.contentMode = .scaleAspectFill
            imageView.frame = captureSessionView.frame
            captureSessionView.addSubview(imageView)
            stopSession()
            updateButtonsStatus(isShooting: false, duration: 0.3)
        } else if let screenShotView = captureSessionView.snapshotView(afterScreenUpdates: true) {
            // スクショ撮影 → jpegImageに変換 → Dataに変換 が成功したらここに入る
            captureSessionView.addSubview(screenShotView)
            stopSession()
            updateButtonsStatus(isShooting: false, duration: 0.3)
        } else {
            print("写真 and スクショ取得失敗")
            updateButtonsStatus(isShooting: true, duration: 0.0)
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
