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
import Alamofire
import AlamofireImage

class MoviesViewController: UIViewController {
    
    @IBOutlet weak var movieTable: UITableView!
    @IBOutlet weak var movieCollection: UICollectionView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var searchBarCtrl: UISearchBar!
    @IBOutlet weak var segmentViewType: UISegmentedControl!
    
    let refreshControl = UIRefreshControl()
    let searchController: UISearchController! = nil
    
    var fullMovieData = [NSDictionary]()
    var filteredMovieData = [NSDictionary]()
    var selectedMovie = NSDictionary()
    
    var endpoint: String = ""
    
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
        
        loadSettings()
        loadJsonData()
        configureCollectionView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func viewTypeChanged(_ sender: AnyObject) {
        movieTable.isHidden = segmentViewType.selectedSegmentIndex == 1 ? true : false
        movieCollection.isHidden = !movieTable.isHidden
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as! MovieDetailViewController
        nextVC.inputMovie = selectedMovie
    }
    
    func loadSettings() {
        segmentViewType.selectedSegmentIndex = 1
        viewTypeChanged(self)
    }
    
    func setBackgroundImgForNavBar(posterPath: String, res: String) {
        Alamofire.request(FlicksUtil.getImageUrl(posterPath: posterPath, res: res), method: .get).responseImage { response in
            if let image = response.result.value {
                self.navigationController?.navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
            }
        }
    }
    
    func loadJsonData() {
        let url = URL(string: FlicksUtil.getApiUrl(endPoint: endpoint))
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
        
        // display loading indicator
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask =
            session.dataTask(with: request,
                             completionHandler: { (dataOrNil, response, error) in
                                // hide HUD once the network request comes back (must be done on main UI thread)
                                MBProgressHUD.hide(for: self.view, animated: true)
                                // check for any errors
                                guard error == nil else {
                                    self.errorView.isHidden = false
                                    return
                                }
                                
                                if let data = dataOrNil {
                                    if let responseDictionary = try! JSONSerialization.jsonObject(
                                        with: data, options:[]) as? NSDictionary {
                                        
                                        self.fullMovieData = responseDictionary["results"] as! [NSDictionary]
                                        self.filteredMovieData = self.fullMovieData
                                        
                                        self.refreshControl.endRefreshing()
                                        
                                        self.movieTable.reloadData()
                                        self.movieCollection.reloadData()
                                    }
                                }
            })
        task.resume()
    }
    
    func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(MoviesViewController.loadJsonData), for: UIControlEvents.valueChanged)
        movieTable.insertSubview(refreshControl, at: 0)
        movieCollection.insertSubview(refreshControl, at: 0)
    }
    
    func setupSearchBar() {
        self.navigationItem.titleView = searchBarCtrl
    }
}

extension MoviesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredMovieData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieCellTableViewCell
        
        // update cell data
        let movieAtIndexPath = filteredMovieData[indexPath.row]
        cell.title.text = movieAtIndexPath["title"] as? String
        cell.desc.text = movieAtIndexPath["overview"] as? String
        cell.thumnail.setImageWith(NSURL(string: FlicksUtil.getImageUrl(posterPath: movieAtIndexPath["poster_path"] as! String, res: Const.Small_Res)) as! URL)
        
        // update cell selection style
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red:0.96, green:0.97, blue:0.70, alpha:1.0)
        backgroundView.layer.borderWidth = 1
        backgroundView.layer.borderColor = UIColor.gray.cgColor
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMovie = filteredMovieData[indexPath.row]
        setBackgroundImgForNavBar(posterPath: filteredMovieData[indexPath.row]["poster_path"] as! String, res: Const.Small_Res)
        performSegue(withIdentifier: "showDetail", sender: self)
    }
}

extension MoviesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return filteredMovieData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMovie = self.filteredMovieData[indexPath.row]
        setBackgroundImgForNavBar(posterPath: filteredMovieData[indexPath.row]["poster_path"] as! String, res: Const.Small_Res)
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCollectionCell",
                                                      for: indexPath) as! MovieCellCollectionViewCell
        // configure the cell
        cell.poster.setImageWith(NSURL(string: FlicksUtil.getImageUrl(posterPath: filteredMovieData[indexPath.row]["poster_path"] as! String, res: Const.Small_Res)) as! URL)
        return cell
    }
    
    func configureCollectionView() {
        // 1
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 80.0, height: 100.0)
        flowLayout.sectionInset = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
        flowLayout.minimumInteritemSpacing = 10.0
        flowLayout.minimumLineSpacing = 10.0
        movieCollection.collectionViewLayout = flowLayout
    }
}

extension MoviesViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovieData = searchText.isEmpty ? fullMovieData : fullMovieData.filter { (item: NSDictionary) -> Bool in
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
        
        filteredMovieData = fullMovieData
        
        movieTable.reloadData()
        movieCollection.reloadData()
    }
}
