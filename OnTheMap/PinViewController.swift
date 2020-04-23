//
//  Created by Cheyo Jimenez on 10/30/15.
//  Copyright © 2015 Cheyo Jimenez. All rights reserved.
//

import UIKit

class PinViewController: UITableViewController, ErrorReportingFromNetworkProtocol {

    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) { }


    @IBAction func logout(_ sender: UIBarButtonItem) {
        logoutPerformer()
    }

    @IBAction func refreshUserLocations(_ sender: UIBarButtonItem) {
        self.presentingAlert = false
        // refreshes user locations
        self.handleRefresh()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh), for: UIControl.Event.valueChanged)
        // refreshes user locations
        getUsersLocationsFromServer()
    }

    @objc func handleRefresh() {
        getUsersLocationsFromServer()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK:- Network Code

    func getUsersLocationsFromServer() {

        self.refreshControl?.beginRefreshing()
        let userLocationOperation = NetworkOperation(typeOfConnection: .getStudentLocationsWithLimit)
        userLocationOperation.delegate = self
        userLocationOperation.completionBlock = {
            DispatchQueue.main.async(execute: {

                self.refreshControl?.endRefreshing()
            })
        }
        userLocationOperation.start()

    }

    func getUsersLocations() -> [UserLocation] {
        getUsersLocationsFromServer()
        return UserDefault.getUserLocations()

    }

    //MARK:- Error Reporting Code

    var errorReported: Error?
    var presentingAlert: Bool = false
    
    func activityIndicatorStart() {
        self.refreshControl?.beginRefreshing()
    }
    
    func activityIndicatorStop() {
        self.refreshControl?.endRefreshing()
    }

    // MARK: - Table view

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserDefault.getUserLocations().count
    }


    // DateFormatter
    private let dateFormatterServer: DateFormatter = {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                        return dateFormatter
                        }()

    private let dateFormatterShort: DateFormatter = {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .short
                        return dateFormatter
                        }()


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewIdentifier", for: indexPath)
        cell.imageView?.image = UIImage(named: "pin")
        let student = UserDefault.getUserLocations()[indexPath.row]
        cell.textLabel?.text = "\( dateFormatterShort.string(from: dateFormatterServer.date(from: student.createdAt) ?? Date.distantFuture)    ) | \(student.fullname):- \(student.mapString)"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let application = UIApplication.shared
        let urlString = UserDefault.getUserLocations()[indexPath.row].mediaURL
        let urlStrinCleaned = urlString.trimmingCharacters(in: CharacterSet.whitespaces)
        if let url = URL(string: urlStrinCleaned) {
            application.openURL(url)
        } else {
            let google = "https://www.google.com/webhp?q=" + urlStrinCleaned
            if let url = URL(string: google) {
                application.openURL(url)
            }
        }
    }
}
