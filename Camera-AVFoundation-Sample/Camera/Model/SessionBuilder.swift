//
//  SessionBuilder.swift
//  Camera-AVFoundation-Sample
//
//  Created by kawaharadai on 2019/07/03.
//  Copyright © 2019 kawaharadai. All rights reserved.
//

import AVFoundation

final class SessionBuilder {

    static func makeCaptureSession() -> (session: AVCaptureSession?, output: AVCapturePhotoOutput?) {

        // デバイスを用意
        guard let defaultDevice = AVCaptureDevice.default(for: .video) else {
            // video用デバイスの生成に失敗
            return (nil, nil)
        }

        /// デバイスへの確認、設定（省略可）

        // 端末のカメラへのアクセスを確認（デバイスのハードウェア関連のプロパティを設定する前に必須、成功なら設定をいじれる）
        if let _ = try? defaultDevice.lockForConfiguration() {
            // フォーカスモードをサポートしている端末か
            if defaultDevice.isFocusModeSupported(.continuousAutoFocus) {
                defaultDevice.focusMode = .continuousAutoFocus
                // フォーカスの焦点は一番近くのものに合わせる
                defaultDevice.autoFocusRangeRestriction = .near
            }
            // デバイスのハードウェア関連のプロパティの設定の終了を宣言
            defaultDevice.unlockForConfiguration()
        }

        /// Input, Outputの生成、設定（AVCapturePhotoSettingsはここでセットする必要はない、撮影時に改めてセットするタイミングがあるため）

        // Output用の出力設定を生成（今回は出力される映像の方を全てjpegにする設定のみ）
        let capturePhotoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])

        // フラッシュの設定
        capturePhotoSettings.flashMode = .auto
        // 最高の解像度を返す
        capturePhotoSettings.isHighResolutionPhotoEnabled = true

        // 出力設定をセット
        let output = AVCapturePhotoOutput()
        output.setPreparedPhotoSettingsArray([capturePhotoSettings], completionHandler: nil)

        // 用意したデバイスからAVCaptureDeviceInputを作成
        guard let input = try? AVCaptureDeviceInput(device: defaultDevice) else {
            // AVCaptureDeviceInputの生成に失敗
            return (nil, nil)
        }

        // カメラ用のSessionを用意
        let session = AVCaptureSession()

        // Session内で作成したinput、outputが使用できるか？
        guard session.canAddInput(input), session.canAddOutput(output) else {
            // input or output がsessionで使用できない
            return (nil, nil)
        }

        // セッションへの代入が可能なら用意したいInputとOutputを入れる
        session.addInput(input)
        session.addOutput(output)

        // 使用可能なSessionを返す
        return (session, output)
    }

}
