//
//  IntroViewController.swift
//  CloudAlarm
//
//  Created by Martin Polednik on 5/16/15.
//  Copyright (c) 2015 cz.fi.muni. All rights reserved.
//

import UIKit

class IntroViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    let introPageViewControllerNames = ["IntroWelcome", "IntroLoginRegister"]
    var introPageViewControllers: [UIViewController] = []
    
    override func viewWillAppear(animated: Bool) {
        let sharedDefaults = NSUserDefaults(suiteName: "group.cz.muni.fi")
        
        sharedDefaults!.setObject("k", forKey: "test")
        sharedDefaults!.synchronize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println(self.introPageViewControllers)
        
        self.dataSource = self
        self.delegate = self

        for pageName in introPageViewControllerNames {
            introPageViewControllers.append(self.storyboard!.instantiateViewControllerWithIdentifier(pageName)! as! UIViewController)
        }
        println(self.introPageViewControllers)
        
        self.setViewControllers([self.introPageViewControllers[0]], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
    }
    
    func viewControllerForIndex(index: Int) -> UIViewController? {
        if (index < 0 || index >= self.introPageViewControllers.count) {
            return nil
        }
        return self.introPageViewControllers[index]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return viewControllerForIndex(find(self.introPageViewControllers, viewController)! - 1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        return viewControllerForIndex(find(self.introPageViewControllers, viewController)! + 1)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.introPageViewControllers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}