
//
//  Created by Cheyo Jimenez on 10/30/15.
//  Copyright © 2015 Cheyo Jimenez. All rights reserved.
//

import UIKit

class PinViewController: UITableViewController {

    @IBAction func logout(sender: UIBarButtonItem) {
        logoutPerformer()
    }
    
    @IBAction func refreshUserLocations(sender: UIBarButtonItem) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    let sampleData = ["something1", "somethng2", "something3", "Something4", "Something5"]
    
    
//    func getUsersLocationsFromServer() {
//        let userLocationOperation = NetworkOperation(typeOfConnection: .getStudentLocationsWithLimit)
//        userLocationOperation.delegate = self
//        userLocationOperation.completionBlock = {
//            dispatch_async(dispatch_get_main_queue(), {
//                
//            })
//        }
//        userLocationOperation.start()
//        
//    }
    
    // MARK: - Table view 
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tableViewIdentifier", forIndexPath: indexPath)

        cell.imageView?.image = UIImage(named: "pin")
        cell.textLabel?.text = "\(sampleData[indexPath.row])"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // if the user did not enter a full URL, do a search with the mediaURL as the search term
//        let https = "https://"
//        let http = "http://"
//        let googleSearch = "https://google.com/search?q="
//        
//        var urlString = mapLocations.locations[indexPath.row].mediaURL
//        if !urlString.hasPrefix(https) && !urlString.hasPrefix(http) {
//            urlString = googleSearch.stringByAppendingString(urlString)
//        }
        let application = UIApplication.sharedApplication()
        if let studentURL = NSURL(string: "https://google.com") {
            application.openURL(studentURL)
        }
    }

}











