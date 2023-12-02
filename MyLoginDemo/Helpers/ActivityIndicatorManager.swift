//
//  ActivityIndicatorManager.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/12/2.
//

import UIKit


class ActivityIndicatorManager {
    
    static let shared = ActivityIndicatorManager()
    
    private var coverView: UIView?
    private var activityIndicator: UIActivityIndicatorView?
    
    /// 初始化活動指示器和覆蓋層
    func activityIndicator(on view: UIView) {
        coverView = UIView(frame: view.bounds)
        coverView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        coverView?.isHidden = true
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator?.center = view.center
        activityIndicator?.hidesWhenStopped = true
        
        coverView?.addSubview(activityIndicator!)
        view.addSubview(coverView!)

    }
    
    /// 啟動活動指示器
    func startLoading() {
        coverView?.isHidden = false
        activityIndicator?.startAnimating()
    }
    
    /// 停止活動指示器
    func stopLoading() {
        activityIndicator?.stopAnimating()
        coverView?.isHidden = true
    }
}


