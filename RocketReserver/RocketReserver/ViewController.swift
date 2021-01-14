//
//  ViewController.swift
//  RocketReserver
//
//  Created by Archna Sukhija on 10/01/21.
//

import UIKit
import SDWebImage
import Apollo

// structure

class ViewController: UIViewController {

    @IBOutlet weak var tblViewData: UITableView!
    var launches = [LaunchListQuery.Data.Launch.Launch]()
    private var lastLaunch: LaunchListQuery.Data.Launch?
    private var activeRequest:Cancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        // Do any additional setup after loading the view.
    }
    
    private func setup() {
        let nib = UINib(nibName: "tblCellOne", bundle: nil)
        self.tblViewData.register(nib, forCellReuseIdentifier: "tblCellOne")
        self.tblViewData.delegate = self
        self.tblViewData.dataSource = self
        self.loadMoreLaunchesIfTheyExist()
    }
    
    private func loadMoreLaunchesIfTheyExist() {
      guard let connection = self.lastLaunch else {
        // We don't have stored launch details, load from scratch
        self.loadLaunches(from: nil)
        return
      }
      guard connection.hasMore else {
        // No more launches to fetch
        return
      }
      self.loadLaunches(from: connection.cursor)
    }

    
    private func loadLaunches(from cursor: String?) {
        self.activeRequest = Network.shared.apollo
        .fetch(query: LaunchListQuery()) { [weak self] result in
          guard let self = self else {
            return
          }
            self.activeRequest = nil

          defer {
            self.tblViewData.reloadData()
          }
                
          switch result {
          case .success(let graphQLResult):
            if let launchConnection = graphQLResult.data?.launches {
              self.lastLaunch = launchConnection
              self.launches.append(contentsOf: launchConnection.launches.compactMap { $0 })
            }
          case .failure(let error):
            print(error.localizedDescription)
          }
      }
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.launches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tblViewData.dequeueReusableCell(withIdentifier: "tblCellOne") as? tblCellOne else {
            return UITableViewCell()
        }
        let launch = self.launches[indexPath.row]
        cell.textLabel?.text = launch.mission?.name
        
        if let missionPatch = launch.mission?.missionPatch {
            cell.imageView?.sd_setImage(with: URL(string: missionPatch)!, placeholderImage: nil)
          } else {
            cell.imageView?.image = nil
          }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == self.launches.count {
            if self.activeRequest == nil {
                  self.loadMoreLaunchesIfTheyExist()
                }
        }
//
//       Network.shared.apollo
//        .fetch(query: LaunchDetailQuery(id: "25")) { [weak self] result in
//          switch result {
//          case .success(let graphQLResult):
//            if let launchConnection = graphQLResult.data?.launch {
//                print(launchConnection.rocket ?? "")
//            }
//          case .failure(let error):
//            print(error.localizedDescription)
//          }
//      }
    }
}

