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
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var overviewLable: UILabel!
    @IBOutlet weak var popularityView: UILabel!
    @IBOutlet weak var releaseDateView: UILabel!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var langLabel: UILabel!
    
    var inputMovie = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.barTintColor = UIColor(red:0.98, green:0.86, blue:0.52, alpha:1.0)
        navigationController?.navigationBar.backgroundColor = UIColor(red:0.98, green:0.86, blue:0.52, alpha:1.0)
        
        popularityView.text = "-/-"
        if let popularity = inputMovie["popularity"]  as? String {
            popularityView.text = "\(Int(popularity))%"
        }
        
        releaseDateView.text = "Unknown"
        if let releaseDateString = inputMovie["release_date"] as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            releaseDateView.text = formatter.string(from: formatter.date(from: releaseDateString)!)
        }
        
        langLabel.text = "-/-"
        if let language = inputMovie["original_language"] as? String {
            langLabel.text = language.uppercased()
        }
        
        voteLabel.text = "-/-"
        if let vote = inputMovie["vote_count"] as? String {
            voteLabel.text = vote
        }
        
        titleView.text = inputMovie["title"] as? String
        
        overviewLable.text = inputMovie["overview"] as? String
        overviewLable.sizeToFit()
        
        // fading in an Image Loaded from the Network
        let smallImageRequest = NSURLRequest(url: NSURL(string: FlicksUtil.getImageUrl(posterPath: inputMovie["poster_path"] as! String, res: Const.Small_Res))! as URL)
        let largeImageRequest = NSURLRequest(url: NSURL(string: FlicksUtil.getImageUrl(posterPath: inputMovie["poster_path"] as! String, res: Const.Large_Res))! as URL)
        
        // TODO: Need to optimize code @here
        // firstly, get the SMALL image
        posterImg.setImageWith(
            smallImageRequest as URLRequest,
            placeholderImage: nil,
            success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                // smallImageResponse will be nil if the smallImage is already available
                // in cache
                if smallImageResponse != nil {
                    print("SMALL image was NOT cached, fade in image")
                    self.posterImg.alpha = 0.0
                    self.posterImg.image = smallImage
                    
                    UIView.animate(
                        withDuration: 0.3,
                        animations: { () -> Void in
                            self.posterImg.alpha = 1.0
                    },
                        completion: { (sucess) -> Void in
                            // get the LARGE image
                            self.posterImg.setImageWith(
                                largeImageRequest as URLRequest,
                                placeholderImage: smallImage,
                                success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                    if largeImageResponse != nil {
                                        print("Large image was NOT cached, fade in image")
                                        self.posterImg.alpha = 0.0
                                        self.posterImg.image = largeImage;
                                        
                                        UIView.animate(
                                            withDuration: 0.3,
                                            animations: { () -> Void in
                                                self.posterImg.alpha = 1.0
                                        })
                                    } else {
                                        print("LARGE IMAGE was cached so just update the image")
                                        self.posterImg.image = largeImage
                                    }
                            },
                                failure: { (request, response, error) -> Void in
                            }
                            )
                    }
                    )
                } else {
                    print("SMALL image was cached so just update the image")
                    self.posterImg.alpha = 0.9
                    self.posterImg.image = smallImage
                    
                    UIView.animate(
                        withDuration: 0.9,
                        animations: { () -> Void in
                            self.posterImg.alpha = 1.0
                    },
                        completion: { (sucess) -> Void in
                            // get the LARGE image
                            self.posterImg.setImageWith(
                                largeImageRequest as URLRequest,
                                placeholderImage: smallImage,
                                success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                    if largeImageResponse != nil {
                                        print("Large image was NOT cached, fade in image")
                                        self.posterImg.alpha = 0.0
                                        self.posterImg.image = largeImage;
                                        
                                        UIView.animate(
                                            withDuration: 0.3,
                                            animations: { () -> Void in
                                                self.posterImg.alpha = 1.0
                                        })
                                    } else {
                                        print("LARGE IMAGE was cached so just update the image")
                                        self.posterImg.image = largeImage
                                    }
                            },
                                failure: { (request, response, error) -> Void in
                            }
                            )
                    }
                    )
                }
            },
            failure: { (request, response, error) -> Void in
            }
        )
        
        infoView.frame.size = CGSize(width: infoView.frame.width, height: titleView.frame.height + releaseDateView.frame.height + overviewLable.frame.height + 30)
        infoView.frame.origin.x = 20
        infoView.frame.origin.y = UIScreen.main.bounds.height - infoView.frame.size.height
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height + 30)
        
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
}
