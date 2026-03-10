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
        let document = UITab(title: "Documents", image: DocumentConstantData.docImage, identifier: "document"){ tab in
            return UINavigationController(rootViewController: ListDocumentAssembler.make())
        }
        
        let password = UITab(title: "Password", image: UIImage(systemName: IconName.password), identifier: "post"){ tab in
            return UINavigationController(rootViewController: MasterPasswordAssembler.make())
        }
        let medical = UITab(title: "Health", image: UIImage(systemName: IconName.medical), identifier: "health") {_ in
            return UINavigationController(rootViewController: ListMedicalAssembler.make())
        }
                
        let settings = UITab(title: "Settings", image: UIImage(systemName: IconName.settings), identifier: "settings") {_ in
            return UINavigationController(rootViewController: SettingsAssembler.make())
        }
        setTabs([document, password, medical,settings], animated: true)
        selectedTab = document
        mode = .automatic
        tabBar.tintColor = AppColor.primaryColor
        tabBarMinimizeBehavior = .onScrollDown

    }
    


}
