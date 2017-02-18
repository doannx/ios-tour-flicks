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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        desc.text = inputMovie["overview"] as? String
        desc.sizeToFit()
        
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
}
