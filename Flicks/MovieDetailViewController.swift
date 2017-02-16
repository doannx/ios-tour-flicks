//
//  MovieDetailViewController.swift
//  Flicks
//
//  Created by john on 2/16/17.
//  Copyright © 2017 doannx. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var posterImg: UIImageView!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var inputMovie = NSDictionary()
    let posterBaseUrl = "https://image.tmdb.org/t/p/w300"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        desc.text = inputMovie["overview"] as? String
        let imgUrl = posterBaseUrl + (inputMovie["poster_path"] as? String)!
        posterImg.setImageWith(NSURL(string: imgUrl) as! URL)
        desc.sizeToFit()
        
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: desc.frame.origin.y + desc.frame.size.height + 10)
        
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -50
        horizontalMotionEffect.maximumRelativeValue = 50
        
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -50
        verticalMotionEffect.maximumRelativeValue = 50
        
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        posterImg.addMotionEffect(motionEffectGroup)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


}
