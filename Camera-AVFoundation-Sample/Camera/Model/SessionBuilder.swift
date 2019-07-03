//
//  SessionBuilder.swift
//  Camera-AVFoundation-Sample
//
//  Created by kawaharadai on 2019/07/03.
//  Copyright © 2019 kawaharadai. All rights reserved.
//

import AVFoundation

final class SessionBuilder {

    static func makeCaptureSession() -> AVCaptureSession? {
        // デバイスを用意
        guard let defaultDevice = AVCaptureDevice.default(for: .video) else {
            print("video用デバイスの生成に失敗")
            return nil
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

        // 用意したデバイスからAVCaptureDeviceInputを作成
        guard let input = try? AVCaptureDeviceInput(device: defaultDevice) else {
            print("AVCaptureDeviceInputの生成に失敗")
            return nil
        }

        // カメラ用のSessionを用意
        let session = AVCaptureSession()

        // Session内で作成したinputが使用できるか？
        guard session.canAddInput(input) else {
            print("inputがsessionで使用できない")
            return nil
        }

        // セッションへの代入が可能なら用意したいInputとOutputを入れる
        session.addInput(input)

        // 使用可能なSessionを返す
        return session
    }

}
