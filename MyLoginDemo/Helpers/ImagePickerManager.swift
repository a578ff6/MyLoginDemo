//
//  ImagePickerManager.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/11/30.
//

import UIKit
import PhotosUI

/// ImagePickerManager: 負責管理和呈現圖片選擇器
class ImagePickerManager: NSObject {

    // 用於完成圖片選擇後的回調
    private var pickerCompletion: ((UIImage?) -> Void)?
    
    /// 呈現圖片選擇器
    /// - Parameters:
    ///   - viewController: 將要呈現圖片選擇器的 UIViewController
    ///   - completion: 選擇圖片後的回調，返回選擇的 UIImage 或 nil
    func presentImagePicker(in viewController: UIViewController, completion: @escaping (UIImage?) -> Void) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        
        viewController.present(picker, animated: true)
        pickerCompletion = completion
    }
}

// MARK: PHPickerViewControllerDelegate 協議的擴展
extension ImagePickerManager: PHPickerViewControllerDelegate {
    
    /// 當圖片選擇完成時調用
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)  // 關閉圖片選擇器
        
        // 檢查是否有選擇圖片
        guard let result = results.first, result.itemProvider.canLoadObject(ofClass: UIImage.self) else {
            pickerCompletion?(nil)
            return
        }
        
        // 加載並返回選擇的圖片
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            DispatchQueue.main.sync {
                self?.pickerCompletion?(image as? UIImage)
            }
        }
    }
}

