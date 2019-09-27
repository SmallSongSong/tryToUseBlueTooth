//
//  extensions.swift
//  tryToUseBlueTooth
//
//  Created by 李松青(SongqingLi)-顺丰科技 on 2019/9/26.
//  Copyright © 2019 李松青(SongqingLi)-顺丰科技. All rights reserved.
//

import UIKit

extension UIViewController {
    func alert(_ message:String, handler: ((UIAlertAction) -> Void)? = nil) -> Void {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "确定", style: .default, handler: handler)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}
