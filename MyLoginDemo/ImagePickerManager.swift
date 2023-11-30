//
//  ImagePickerManager.swift
//  MyLoginDemo
//
//  Created by 曹家瑋 on 2023/11/30.
//

import UIKit
import PhotosUI

class ImagePickerManager: NSObject {

    private var pickerCompletion: ((UIImage?) -> Void)?
    
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

extension ImagePickerManager: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first, result.itemProvider.canLoadObject(ofClass: UIImage.self) else {
            pickerCompletion?(nil)
            return
        }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            DispatchQueue.main.sync {
                self?.pickerCompletion?(image as? UIImage)
            }
        }
    }
}

