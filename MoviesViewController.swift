//
//  MoviesViewController.swift
//  Flicks
//
//  Created by john on 2/15/17.
//  Copyright © 2017 doannx. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var movieTable: UITableView!
    @IBOutlet weak var errorView: UIView!
    
    var movieData = [NSDictionary]()
    
    let posterBaseUrl = "https://image.tmdb.org/t/p/w300"
    
    var selectedMovie = NSDictionary()
    
    let refreshControl = UIRefreshControl()
    var endpoint: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        movieTable.delegate = self
        movieTable.dataSource = self
        setupRefreshControl()
        self.loadJsonData()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movieData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieCellTableViewCell
        cell.title.text = self.movieData[indexPath.row]["title"] as? String
        cell.desc.text = self.movieData[indexPath.row]["overview"] as? String
        let imgUrl = posterBaseUrl + (self.movieData[indexPath.row]["poster_path"] as? String)!
        cell.thumnail.setImageWith(NSURL(string: imgUrl) as! URL)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMovie = self.movieData[indexPath.row]
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let nextVC = segue.destination as! MovieDetailViewController
        nextVC.inputMovie = selectedMovie
        
        
        
    }
    
    func loadJsonData() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = URLRequest(
            url: url!,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        errorView.isHidden = true
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask =
            session.dataTask(with: request,
                             completionHandler: { (dataOrNil, response, error) in
                                // Hide HUD once the network request comes back (must be done on main UI thread)
                                MBProgressHUD.hide(for: self.view, animated: true)
                                // check for any errors
                                guard error == nil else {
                                    self.errorView.isHidden = false
                                    return
                                }
                                
                                if let data = dataOrNil {
                                    if let responseDictionary = try! JSONSerialization.jsonObject(
                                        with: data, options:[]) as? NSDictionary {
                                        print("response: \(responseDictionary)")
                                        self.movieData = responseDictionary["results"] as! [NSDictionary]
                                        self.movieTable.reloadData()
                                        self.refreshControl.endRefreshing()
                                        
                                    }
                                }
            })
        task.resume()
    }
    
    func setupRefreshControl() {
        //refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MoviesViewController.loadJsonData), for: UIControlEvents.valueChanged)
        movieTable.insertSubview(refreshControl, at: 0)
    }
    
}
