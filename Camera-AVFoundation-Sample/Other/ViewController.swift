//
//  ViewController.swift
//  Camera-AVFoundation-Sample
//
//  Created by kawaharadai on 2019/07/03.
//  Copyright © 2019 kawaharadai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func didTapCameraButton(_ sender: UIButton) {

        let captureSession = SessionBuilder.makeCaptureSession()
        guard let session = captureSession.session, let output = captureSession.output else {
            print("Sessionの生成に失敗")
            return
        }

        let cameraVC = CameraViewController(session: session, output: output)

        // カメラへのアクセス状態を確認
        if CameraAccessPermission.needsToRequestAccess {
            // アクセス許可がないためリクエスト
            CameraAccessPermission.requestAccess { (isAccess) in
                // アクセスが許可されたらカメラを作る
                guard isAccess else {
                    print("ユーザーがカメラ使用を拒否した")
                    return
                }

                // handlerが返るのはsubThreadで、カメラはmainTheadで作る必要がある
                DispatchQueue.main.async { [weak self] in
                    self?.present(cameraVC, animated: true)
                }
            }
        } else {
            present(cameraVC, animated: true)
        }

    }

}

