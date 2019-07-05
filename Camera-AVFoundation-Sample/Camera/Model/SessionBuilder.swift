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

        /// Inputの生成、設定（AVCapturePhotoSettingsはここでセットする必要はない、撮影時に改めてセットするタイミングがあるため）

        // 用意したデバイスからAVCaptureDeviceInputを作成
        guard let input = try? AVCaptureDeviceInput(device: defaultDevice) else {
            print("AVCaptureDeviceInputの生成に失敗")
            return nil
        }
        // カメラ用のSessionを用意、設定を開始
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = .photo

        // Session内で作成したinputが使用できるか？
        guard session.canAddInput(input) else {
            print("inputがsessionで使用できない")
            return nil
        }

        session.addInput(input)

        // 設定完了
        session.commitConfiguration()
        
        return session
    }

}
