//
//  ViewController.swift
//  FFWalkthrough
//
//  Created by Mikhail Malyshev on 01.10.17.
//  Copyright © 2017 Mikhail Malyshev. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var switcher: UISwitch!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tabbar: UITabBar!
    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.switcher.addTarget(self, action: #selector(ViewController.switcherAction), for: .valueChanged)
        
    }
    
    func setupNavBar(){
        let img = UIImageView(image: UIImage(named: "coins"))
        let item = UIBarButtonItem(customView: img)
        self.navigationItem.rightBarButtonItem = item
    }
    
    
    func switcherAction(){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            if self.switcher.isOn {
                let model1 = FFWalkthroughModel(highlighted: self.slider, custom: [], title: "😱 OMG! 😱\n😱😱😱😱")
                model1.titleLocation = .bottomCenter
                let model2 = FFWalkthroughModel(highlighted: self.segmentControl, custom: [], title: "Multiple highlighted views at once")
                model2.titleLocation = .bottomCenter
                let model3 = FFWalkthroughModel(highlighted: self.image, custom: [], title: "My money")
                model3.titleLocation = .bottomRight
                
                let wlth = FFWalkthroughView(root: self.navigationController!.view, elements: [model1, model2, model3])
                wlth.animationDuration = 0.0
                wlth.present()

            } else {
                let model1 = FFWalkthroughModel(highlighted: self.switcher, custom: [], title: nil, custom: { (element, root) in
                    let img = UIImageView(image: UIImage(named: "SuccessTutorialImage"))
                    img.contentMode = .scaleAspectFit
                    img.bounds = root.bounds
                    let label = UILabel(frame: CGRect(origin: CGPoint.zero, size: root.bounds.size))
                    label.numberOfLines = 0
                    label.text = "Easy, easy! \nReal talk!"
                    label.textAlignment = .center
                    label.font = UIFont.systemFont(ofSize: 32, weight: 20)
                    label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    
                    root.addSubview(img)
                    root.addSubview(label)
                    
                    img.center = root.center
                    label.center = img.center
                })
                model1.customPrepareType = .before
                
                let wlth = FFWalkthroughView(root: self.navigationController!.view, elements: [model1])
                wlth.animationDuration = 1.0
                wlth.blurColor = #colorLiteral(red: 0.5498302816, green: 0.5871527308, blue: 1, alpha: 0.2406517551)
                wlth.present()

            }
        }
    }
    
    
    
    
    
    
    


}

