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
    
    var inputMovie = NSDictionary()
    let posterBaseUrl = "https://image.tmdb.org/t/p/w300"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        desc.text = inputMovie["overview"] as? String
        let imgUrl = posterBaseUrl + (inputMovie["poster_path"] as? String)!
        posterImg.setImageWith(NSURL(string: imgUrl) as! URL)
        desc.sizeToFit()
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
