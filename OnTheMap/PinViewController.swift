
//
//  Created by Cheyo Jimenez on 10/30/15.
//  Copyright © 2015 Cheyo Jimenez. All rights reserved.
//

import UIKit

class PinViewController: UITableViewController, ErrorReportingFromNetworkProtocol {

    @IBAction func logout(sender: UIBarButtonItem) {
        logoutPerformer()
    }
    
    @IBAction func refreshUserLocations(sender: UIBarButtonItem) {
        self.presentingAlert = false
        // refreshes user locations
        self.handleRefresh()
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh), forControlEvents: UIControlEvents.ValueChanged)
        // refreshes user locations
        getUsersLocationsFromServer()
    }
    
    func handleRefresh() {
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
            dispatch_async(dispatch_get_main_queue(), {
                
        self.refreshControl?.endRefreshing()
            })
        }
        userLocationOperation.start()
        
    }
    
    func getUsersLocations() -> [UserLocation]{
        getUsersLocationsFromServer()
        return UserDefault.getUserLocations()
        
    }
    
    
    
    //MARK:- Error Reporting Code
    
    private(set) var errorReported:ErrorType?
    private var presentingAlert:Bool = false
    
    func reportErrorFromOperation(operationError: ErrorType?) {
        if let operationError = operationError where
            self.errorReported == nil && presentingAlert == false {
            self.errorReported = operationError
            let descriptionError = (operationError as NSError).localizedDescription
            self.presentErrorPopUp(descriptionError, presentingError: &presentingAlert)
            self.refreshControl?.endRefreshing()

        } else {
            self.errorReported = nil
        }
    }
    
    // MARK: - Table view 
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserDefault.getUserLocations().count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tableViewIdentifier", forIndexPath: indexPath)

        cell.imageView?.image = UIImage(named: "pin")
        cell.textLabel?.text = "\(UserDefault.getUserLocations()[indexPath.row].fullname)"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let application = UIApplication.sharedApplication()
        let urlString = UserDefault.getUserLocations()[indexPath.row].mediaURL
        application.openURL(NSURL(string: urlString)!)
    }



}
