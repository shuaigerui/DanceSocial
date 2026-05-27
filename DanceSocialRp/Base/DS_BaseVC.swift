//
//  DS_BaseVC.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

class DS_BaseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        // 隐藏导航栏（整个导航栏会消失）
        navigationController?.navigationBar.isHidden = true
    }

}
