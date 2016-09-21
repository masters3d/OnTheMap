//
//  NetworkLayer.swift
//  OnTheMap
//
//  Created by Cheyo Jimenez on 5/10/16.
//  Copyright © 2016 Cheyo Jimenez. All rights reserved.
//

import UIKit

enum APIConstants {
    static let udacitySession  = "https://www.udacity.com/api/session"
    static let udacityUsers = "https://www.udacity.com/api/users/"
    static let parseStudentLocation = "https://parse.udacity.com/parse/classes/StudentLocation"
    static let parseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let parseHeaderAppID = "X-Parse-Application-Id"
    static let parseRestAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    static let parseHeaderForREST = "X-Parse-REST-API-Key"
}

protocol ErrorReportingFromNetworkProtocol: class {
    func reportErrorFromOperation(_ operationError: Error?)
    var errorReported: Error? { get set }
    var presentingAlert: Bool { get set }
    
    //activityIndicator.startAnimating()
    func activityIndicatorStart()
    func activityIndicatorStop()
}

class NetworkOperation: Operation, URLSessionDataDelegate {
    //Error Reporting
    var delegate: ErrorReportingFromNetworkProtocol?

    // custom fields
    fileprivate var url: URL?
    fileprivate var keyString: String?
    var request: URLRequest?

    // default
    fileprivate var data = NSMutableData()
    fileprivate var startTime: TimeInterval? = nil
    fileprivate var totalTime: TimeInterval? = nil
    

    // Still need this workaround to overide getter only isFinish
    fileprivate var tempFinished: Bool = false
    override var isFinished: Bool {
        set {
            willChangeValue(forKey: "isFinished")
            tempFinished = newValue
            didChangeValue(forKey: "isFinished")
        }
        get {
            return tempFinished
        }
    }

    override func start() {

        // clears up any errors in the delegate
        DispatchQueue.main.async(execute: {
            self.delegate?.reportErrorFromOperation(nil)
        })

        if isCancelled {
            isFinished = true
            return
        }

        let config = URLSessionConfiguration.default
        let session = Foundation.URLSession(configuration: config, delegate: self, delegateQueue: nil)

        // session name for debugging
        session.sessionDescription = keyString

        if let request = request {
            let task = session.dataTask(with: request)
            startTime = Date.timeIntervalSinceReferenceDate
            task.resume()
        }
    }

    init(url: URL, keyForData: String) {
        super.init()
        self.url = url
        self.keyString = keyForData
        self.request = URLRequest(url: url)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {

        guard let httpResponse = response as? HTTPURLResponse else {
            fatalError("Unexpected response type")
        }

        switch httpResponse.statusCode {
        case 200:
            completionHandler(.allow)
        case 201:
            completionHandler(.allow)
        default:
            let connectionError = NSError(domain: "Check your login information.", code: httpResponse.statusCode, userInfo: nil)
            print(connectionError.localizedDescription)
            DispatchQueue.main.async(execute: {
                self.delegate?.reportErrorFromOperation(connectionError)
            })
            completionHandler(.cancel)
            isFinished = true
        }
        print("return code for server: \(httpResponse.statusCode) for session: \(session.sessionDescription ?? warnLog("no description"))")
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive incomingData: Data) {
        data.append(incomingData)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Failed! \(error)")
            // sending error to delagate UI on the main queue
            DispatchQueue.main.async(execute: {
                self.delegate?.reportErrorFromOperation(error)
            })

            isFinished = true
            return
        }

        //MARk:-ProcessData() and save
        // Right now we are just saving here for later retrival
        UserDefaults.standard.set(data, forKey: keyString ?? warnLog(""))

        totalTime = Date.timeIntervalSinceReferenceDate - startTime! // this should always have a value
        isFinished = true
    }
}

//MARK: - Udacity & Udacity Parse Connection

enum ConnectionType: String {
    case login = "udacityLoginResponse"
    case getFullName = "getFullNameResponse"
    case getStudentLocationsWithLimit = "ParseAPILocationsWithLimit"
    case getLoggedInStudentMultipleLocations = "ParseLoggedInStudentLocation"
    case postLoggedInStudentLocation = "ParsePostLoggedInStudentLocation"
    case putUpdateStudentLocation = "ParsePutUpdateStudentLocation"
    case deleteSession = "udacityLogOutSession"  // currently using something manual in shareview code
}

extension NetworkOperation {
    convenience init(typeOfConnection: ConnectionType) {
        switch typeOfConnection {
        case .login:
            self.init(url:URL(string: APIConstants.udacitySession)!, keyForData:typeOfConnection.rawValue)
            request?.httpMethod = "POST"
            request?.addValue("application/json", forHTTPHeaderField: "Accept")
            request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request?.httpBody = UserDefault.getHTTPBodyUdacityPayload()

        case .getFullName:
            let userID = UserDefault.getUserId() ?? warnLog("")
            guard let getFullNameURL = URL(string: APIConstants.udacityUsers + "\(userID)") else { fatalError("Malformed URL")}
            self.init(url:getFullNameURL, keyForData:typeOfConnection.rawValue)

        case .deleteSession:
            let sessionID = UserDefault.getCurrentSessionID() ?? warnLog("")
            self.init(url:URL(string: APIConstants.udacitySession)!, keyForData:typeOfConnection.rawValue)
            request?.httpMethod = "DELETE"
            request?.setValue(sessionID, forHTTPHeaderField: "X-XSRF-TOKEN")

        //MARK: - Parse Connections
        case .getStudentLocationsWithLimit:
            self.init(url:NetworkOperation.parseEscapedURL(), keyForData: typeOfConnection.rawValue)
            request?.addParseHeaderAndAPIFields()
            request?.addValue("100", forHTTPHeaderField: "limit")
            request?.addValue("-updatedAt", forHTTPHeaderField: "order")

        case .getLoggedInStudentMultipleLocations:
            let userId = UserDefault.getUserId() ?? warnLog("")
            self.init(url:NetworkOperation.parseEscapedForUserID(userId), keyForData: typeOfConnection.rawValue)
            request?.addParseHeaderAndAPIFields()
            //Alternative to building URL: request?.addValue("{\"uniqueKey\":\"\(userId)\"}", forHTTPHeaderField: "where")

        case .postLoggedInStudentLocation:
            self.init(url:NetworkOperation.parseEscapedURL(), keyForData: typeOfConnection.rawValue)
            request?.addParseHeaderAndAPIFields()
            request?.httpMethod = "POST"
            request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request?.httpBody = UserDefault.postParsePayload

        case .putUpdateStudentLocation:
            let mostRecentObject = UserDefault.getCurrentLoggedInUserLocations().last?.objectId ?? warnLog("")
            let url = URL(string: APIConstants.parseStudentLocation + "/\(mostRecentObject)" )
            self.init(url:url!, keyForData: typeOfConnection.rawValue)
            request?.addParseHeaderAndAPIFields()
            request?.httpMethod = "PUT"
            request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request?.httpBody = UserDefault.postParsePayload
        }
    }
}

extension URLRequest {

    mutating func addParseHeaderAndAPIFields() {
        self.addValue(APIConstants.parseApplicationID, forHTTPHeaderField: APIConstants.parseHeaderAppID)
        self.addValue(APIConstants.parseRestAPIKey, forHTTPHeaderField: APIConstants.parseHeaderForREST)
    }
}



extension NetworkOperation {

    static func escapeForURL(_ input: String) -> String? {
        return input.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    }

    static func parseEscapedURLforObjectID(_ objectID: String) -> URL {
        let parseURL = APIConstants.parseStudentLocation
        guard let parseURLEscaped = URL(string: ( NetworkOperation.escapeForURL(parseURL + "/\(objectID)" )) ?? warnLog(parseURL)) else { fatalError("Malformed URL") }
        return parseURLEscaped
    }

    static func parseEscapedForUserID(_ userId: String) -> URL {
        let parseURL = APIConstants.parseStudentLocation
        let userIDwhere =  "?where={\"uniqueKey\":\"\(userId)\"}"

        guard let parseURLEscaped = URL(string: ( NetworkOperation.escapeForURL(parseURL + userIDwhere  )) ?? warnLog(parseURL)) else { fatalError("Malformed URL") }
        return parseURLEscaped

    }
    static func parseEscapedURL() -> URL {
        let parseURL = APIConstants.parseStudentLocation
        guard let parseURLEscaped = URL(string: NetworkOperation.escapeForURL(parseURL ) ?? warnLog(parseURL)) else { fatalError("Malformed URL") }
        return parseURLEscaped

    }

}
