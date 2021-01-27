//
//  AboutUsVC.swift
//  IFHAM
//
//  Created by AngelDev on 6/3/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit

class AboutUsVC: BaseAndMenuVC {

    @IBOutlet weak var txvAbout: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }
    
    func initView() {
        self.title = "About IFHAM"
        setNavigationBarColors()
        
        txvAbout.text = """
                It is our hope to inspire you with fresh perspectives and to empower you with practical, effective strategies and resources that transform the learning and teaching experience.

                We welcome all who want to enrich their learning and teaching by offering a wide range of programs and services. The Supplemental Instruction sections and Tutorial Centers will help you master course content and develop study strategies for specific courses.

                We believe in you and know that you can excel at IFHAM. We want to give you a perspective on learning that will help you accomplish your academic and career goals. You can do it, and we can help!
                We look forward to seeing you often at the learning Center of IFHAM!
            """
    }

}
