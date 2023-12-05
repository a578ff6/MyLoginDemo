//
//  FirstViewController.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/11/28.
//

import UIKit
import AVFoundation

/// 初次登入或註冊選擇的介面
class FirstViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!


    
    
    /// 影片播放器
    var videoPlayer: AVPlayer?
    
    /// 影片播放器的Layer
    var videoPlayerLayer: AVPlayerLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

       setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpVideo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 影片播放完畢或離開當前頁面時，移除通知觀察者
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: videoPlayer?.currentItem)
    }

    
    /// 設定按鈕樣式
    func setUpElements() {
        Utilities.styleHollowButton(loginButton)
        Utilities.styleFilledButton(signUpButton)
    }
    
    
    /// 設定並播放背景影片
    func setUpVideo() {
        
        // 移除現有的 videoPlayerLayer 避免重複播放
        videoPlayerLayer?.removeFromSuperlayer()

        // 確保影片存在
        guard let bundlePath = Bundle.main.path(forResource: "LoginVideo", ofType: "mp4") else {
            return
        }

        let url = URL(fileURLWithPath: bundlePath)

        // 創建 AVPlayerItem
        let item = AVPlayerItem(url: url)

        // 初始化 AVPlayer
        videoPlayer = AVPlayer(playerItem: item)

        // 創建 AVPlayerLayer
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer!)

        videoPlayerLayer?.frame = view.bounds
        videoPlayerLayer?.videoGravity = .resizeAspectFill // 調整影片填充模式

        // 添加 videoPlayerLayer 到 view 的 layer
        view.layer.insertSublayer(videoPlayerLayer!, at: 0)
        
        // 監聽影片播放結束通知
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnd), name: .AVPlayerItemDidPlayToEndTime, object: item)

        videoPlayer?.play()
    }

    /// 影片播放結束時，重新播放
    @objc func videoDidEnd() {
        videoPlayer?.seek(to: CMTime.zero)
        videoPlayer?.play()
    }


}

