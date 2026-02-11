//
//  TabBarController.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        setUpContents()
    }
    
    func setUpContents() {
        let document = UITab(title: "Documents", image: UIImage(systemName: "doc"), identifier: "document"){ tab in
            return UINavigationController(rootViewController: ListDocumentAssembler.make())
        }
        
        let password = UITab(title: "PassWord", image: UIImage(systemName: "key.shield"), identifier: "post"){ tab in
            return UINavigationController(rootViewController: MasterPasswordAssembler.make())
        }
        let medical = UITab(title: "Medical", image: UIImage(systemName: "medical.thermometer"), identifier: "medical") {_ in 
            return UINavigationController(rootViewController: ListMedicalAssembler.make())
        }
        setTabs([document, password, medical], animated: true)
        selectedTab = document
        mode = .tabSidebar
        tabBar.tintColor = AppColor.primaryColor
    }
    


}
