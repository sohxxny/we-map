//
//  TabBarViewController.swift
//  WeMap
//
//  Created by Lee Soheun on 5/14/24.
//

import UIKit

class TabBarViewController: BaseViewController, UITabBarDelegate {
    
    @IBOutlet weak var tabBar: UITabBar!
    
    var currentViewController: UIViewController!
    var homeViewController: HomeViewController!
    var friendsListViewController: UINavigationController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.delegate = self
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
        friendsListViewController = storyboard.instantiateViewController(withIdentifier: "FriendsList") as? UINavigationController
        currentViewController = homeViewController

        tabBar.selectedItem = tabBar.items?.first(where: { $0.tag == 2 })
        switchToViewController(homeViewController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 4 {
            switchToViewController(friendsListViewController)
        } else {
            if !(currentViewController is HomeViewController) {
                switchToViewController(homeViewController)
            }
        }
    }
    
    func switchToViewController(_ viewController: UIViewController) {
        // 현재 모든 자식 뷰 컨트롤러를 컨테이너에서 제거
        children.forEach {
            $0.willMove(toParent: nil)
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
        
        // 새 뷰 컨트롤러를 추가
        addChild(viewController)
        currentViewController = viewController
        viewController.view.frame = view.bounds
        view.insertSubview(viewController.view, at: 0) // 탭바 아래에 뷰를 놓음
        viewController.didMove(toParent: self)
    }
}
