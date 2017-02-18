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
import SwiftyJSON

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var movieTable: UITableView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var movieCollection: UICollectionView!
    @IBOutlet weak var searchBarCtrl: UISearchBar!
    @IBOutlet weak var segmentViewType: UISegmentedControl!
    
    var movieData = [NSDictionary]()
    var filteredMovies = [NSDictionary]()
    var selectedMovie = NSDictionary()
    
    let refreshControl = UIRefreshControl()
    var searchController: UISearchController!
    
    let posterBaseUrl = "https://image.tmdb.org/t/p/w300"
    var endpoint: String = ""
    
    @IBAction func viewTypeChanged(_ sender: AnyObject) {
        if(segmentViewType.selectedSegmentIndex==1){
            movieTable.isHidden = true
            movieCollection.isHidden = false
        }else{
            movieTable.isHidden = false
            movieCollection.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        movieTable.delegate = self
        movieTable.dataSource = self
        movieCollection.delegate = self
        movieCollection.dataSource = self
        searchBarCtrl.delegate = self
        
        
        setupRefreshControl()
        
        setupSearchBar()
        
        segmentViewType.selectedSegmentIndex = 1
        viewTypeChanged(self)
        
        self.loadJsonData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieCellTableViewCell
        
        let movieAtIndexPath = self.filteredMovies[indexPath.row]
        cell.title.text = movieAtIndexPath["title"] as? String
        cell.desc.text = movieAtIndexPath["overview"] as? String
        let imgUrl = posterBaseUrl + (movieAtIndexPath["poster_path"] as? String)!
        cell.thumnail.setImageWith(NSURL(string: imgUrl) as! URL)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMovie = self.filteredMovies[indexPath.row]
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
                                        
                                        self.movieData = responseDictionary["results"] as! [NSDictionary]
                                        self.filteredMovies = self.movieData
                                        
                                        self.refreshControl.endRefreshing()
                                        
                                        self.movieTable.reloadData()
                                        self.movieCollection.reloadData()
                                    }
                                }
            })
        task.resume()
    }
    
    func setupRefreshControl() {
        // refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MoviesViewController.loadJsonData), for: UIControlEvents.valueChanged)
        
        movieTable.insertSubview(refreshControl, at: 0)
        movieCollection.insertSubview(refreshControl, at: 0)
    }
    
    func setupSearchBar() {
        //searchController = UISearchController(searchResultsController: nil)
        //searchController.searchResultsUpdater = self
        //searchController.dimsBackgroundDuringPresentation = false
        //definesPresentationContext = true
        //movieTable.tableHeaderView = searchController.searchBar
        self.navigationItem.titleView = searchBarCtrl
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMovie = self.filteredMovies[indexPath.row]
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCollectionCell",
                                                      for: indexPath) as! MovieCellCollectionViewCell
        // Configure the cell
        let movieAtIndexPath = filteredMovies[indexPath.row]
        let imgUrl = posterBaseUrl + (movieAtIndexPath["poster_path"] as? String)!
        cell.poster.setImageWith(NSURL(string: imgUrl) as! URL)
        
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = searchText.isEmpty ? movieData : movieData.filter { (item: NSDictionary) -> Bool in
            return (item["title"] as! String).contains(searchText)
        }
        
        movieTable.reloadData()
        movieCollection.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBarCtrl.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        searchBarCtrl.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarCtrl.showsCancelButton = false
        searchBarCtrl.text = ""
        searchBarCtrl.resignFirstResponder()
        filteredMovies = movieData
        
        movieTable.reloadData()
        movieCollection.reloadData()
    }
    
}

