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
    
    var loadingMoreViewTable: InfiniteScrollActivityView?
    var loadingMoreViewCollection: InfiniteScrollActivityView?
    
    let refreshControl = UIRefreshControl()
    let searchController: UISearchController! = nil
    
    var fullMovieData = [NSDictionary]()
    var filteredMovieData = [NSDictionary]()
    
    var selectedMovie = NSDictionary()
    
    var endpoint: String = ""
    var isMoreDataLoading = false
    let scrollOffsetThreshold = 300
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        movieTable.delegate = self
        movieTable.dataSource = self
        movieCollection.delegate = self
        movieCollection.dataSource = self
        searchBarCtrl.delegate = self
        
        setupInfiniteLoadingView()
        setupRefreshControl()
        setupSearchBar()
        configureCollectionView()
        
        loadSettings()
        
        loadJsonData()
        
        navigationController?.navigationBar.barTintColor = UIColor(red:0.98, green:0.86, blue:0.52, alpha:1.0)
        navigationController?.navigationBar.backgroundColor = UIColor(red:0.98, green:0.86, blue:0.52, alpha:1.0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let backdropPath = selectedMovie["backdrop_path"] as? String
        if (backdropPath != nil) {
            setBackgroundImgForNavBar(posterPath: backdropPath!, res: Const.Large_Res)
        }
    }
    
    @IBAction func viewTypeChanged(_ sender: AnyObject) {
        movieTable.isHidden = segmentViewType.selectedSegmentIndex == 1 ? true : false
        movieCollection.isHidden = !movieTable.isHidden
        
        UserDefaults.standard.saveViewOption(viewOption: segmentViewType.selectedSegmentIndex)
        
        if segmentViewType.selectedSegmentIndex == 0 {
            movieTable.insertSubview(refreshControl, at: 0)
            
            movieTable.addSubview(loadingMoreViewTable!)
            
            var insets = movieTable.contentInset
            insets.bottom += InfiniteScrollActivityView.defaultHeight
            movieTable.contentInset = insets
        } else {
            movieCollection.insertSubview(refreshControl, at: 0)
            
            movieCollection.addSubview(loadingMoreViewTable!)
            
            var insetsCollection = movieCollection.contentInset
            insetsCollection.bottom += InfiniteScrollActivityView.defaultHeight
            movieCollection.contentInset = insetsCollection
        }
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as! MovieDetailViewController
        nextVC.inputMovie = selectedMovie
    }
    
    func loadSettings() {
        segmentViewType.selectedSegmentIndex = UserDefaults.standard.loadViewOption()
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
                                    self.searchBarCtrl.isHidden = true
                                    return
                                }
                                
                                if let data = dataOrNil {
                                    if let responseDictionary = try! JSONSerialization.jsonObject(
                                        with: data, options:[]) as? NSDictionary {
                                        
                                        self.fullMovieData = responseDictionary["results"] as! [NSDictionary]
                                        
                                        let lastSearchValue = UserDefaults.standard.loadSearchValue()
                                        
                                        self.filteredMovieData = lastSearchValue.isEmpty ? self.fullMovieData : self.fullMovieData.filter { (item: NSDictionary) -> Bool in
                                            return (item["title"] as! String).contains(lastSearchValue)
                                        }
                                        
                                        self.searchBarCtrl.text = lastSearchValue
                                        
                                        self.refreshControl.endRefreshing()
                                        
                                        self.movieTable.reloadData()
                                        self.movieCollection.reloadData()
                                    }
                                }
            })
        task.resume()
    }
    
    func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(loadJsonData), for: UIControlEvents.valueChanged)
        
        if segmentViewType.selectedSegmentIndex == 0 {
            movieTable.insertSubview(refreshControl, at: 0)
        } else {
            movieCollection.insertSubview(refreshControl, at: 0)
        }
    }
    
    func setupSearchBar() {
        self.navigationItem.titleView = searchBarCtrl
    }
    
    func setupErrorView() {
        errorView.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MoviesViewController.onErrorViewTap))
        errorView.addGestureRecognizer(tapGesture)
    }
    
    func onErrorViewTap(sender: AnyObject) {
        loadJsonData()
    }
    
    func setupInfiniteLoadingView() {
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: movieTable.contentSize.height, width: movieTable.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreViewTable = InfiniteScrollActivityView(frame: frame)
        loadingMoreViewTable!.isHidden = true
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
        
        UserDefaults.standard.saveSearchValue(lastSearchValue: searchText)
        
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
        
        UserDefaults.standard.saveSearchValue(lastSearchValue: "")
        
        movieTable.reloadData()
        movieCollection.reloadData()
    }
}

extension MoviesViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = segmentViewType.selectedSegmentIndex == 0 ? movieTable.contentSize.height : movieCollection.contentSize.height
            let scrollOffsetThreshold = segmentViewType.selectedSegmentIndex == 0 ? scrollViewContentHeight - movieTable.bounds.size.height : scrollViewContentHeight - movieCollection.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && (movieTable.isDragging || movieCollection.isDragging)) {
                isMoreDataLoading = true
                
                // update position of loadingMoreView, and start loading indicator
                let y = segmentViewType.selectedSegmentIndex == 0 ? movieTable.contentSize.height : movieCollection.contentSize.height
                let width = segmentViewType.selectedSegmentIndex == 0 ? self.movieTable.bounds.size.width : self.movieCollection.bounds.size.width
                let frame = CGRect(x: 0, y: y, width: width, height: InfiniteScrollActivityView.defaultHeight)
                self.loadingMoreViewTable?.frame = frame
                self.loadingMoreViewTable!.startAnimating()
                
                loadMoreData()
            }
            
        }
    }
    
    func loadMoreData() {
        
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
        
        let task : URLSessionDataTask =
            session.dataTask(with: request, completionHandler: { (data, response, error) in
                // update flag
                self.isMoreDataLoading = false
                
                // stop the loading indicator
                self.loadingMoreViewTable!.stopAnimating()
                // TODO: updating data
                                                                
                // Reload the tableView now that there is new data
                self.movieTable.reloadData()
                self.movieCollection.reloadData()
            })
        task.resume()
    }
}
