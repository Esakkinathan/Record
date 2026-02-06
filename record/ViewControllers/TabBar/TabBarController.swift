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
            return UINavigationController(rootViewController: ListDocumentAssembler.makeListDocumentScreen())
        }
        
        let password = UITab(title: "PassWord", image: UIImage(systemName: "ellipsis.bubble"), identifier: "post"){ tab in
            return UINavigationController(rootViewController: MasterPasswordAssembler.make())
        }
        
        setTabs([document, password], animated: true)
        selectedTab = document
        mode = .tabSidebar
        tabBar.tintColor = AppColor.primaryColor
    }
    


}
