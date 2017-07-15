//
//  NetworkController.swift
//  FöliGuide
//
//  Created by Jonas on 26/01/16.
//  Copyright © 2016 Capstone Innovation Project - Route Guidance. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NetworkController: NSObject {

    static var requestActive = false
    static var latestRequest: Request? // Latest request, so it can be cancelled if new one comes in


    static var gtfsDataURL: String?


    // Gets bus data from API, calls completionhandler with nil if data invalid
    class func getBusData(_ completionHandler: @escaping (JSON?) -> Void) {
        requestActive = true

        latestRequest = Alamofire.request(Constants.API.RealTimeBusURL, method: .get)
            .responseData { response in
                //				print(response.request)

                requestActive = false


                switch response.result {

                case .success(let data):
                    completionHandler(JSON(data: data))

                case .failure:
                    completionHandler(nil)
                }

        }
    }

    // Gets bus stop data from API, calls completionhandler with nil if data invalid
    class func getBusStopData(_ completionHandler: @escaping (JSON?) -> Void) {

        getJSONData(fromURL: Constants.API.BusStopURL, completionHandler: completionHandler)
    }

    class func getRoutesData(_ completionHandler: @escaping (JSON?) -> Void) {

        if let gtfsURL = gtfsDataURL {
            getJSONData(fromURL: "\(gtfsURL)/routes", completionHandler: completionHandler)
        } else {
            getGTFSDataURL({ (gtfsURL) in
                if let url = gtfsURL {
                    gtfsDataURL = url
                    getJSONData(fromURL: "\(url)/routes", completionHandler: completionHandler)
                } else {
                    completionHandler(nil)
                }
            })

        }
    }

    class func getTripsData(withRouteID routeID: String, completionHandler: @escaping (JSON?) -> Void) {

        if let gtfsURL = gtfsDataURL {
            getJSONData(fromURL: "\(gtfsURL)/trips/route/\(routeID)", completionHandler: completionHandler)
        } else {
            getGTFSDataURL({ (gtfsURL) in
                if let url = gtfsURL {
                    gtfsDataURL = url
                    getJSONData(fromURL: "\(url)/trips/route/\(routeID)", completionHandler: completionHandler)
                } else {
                    completionHandler(nil)
                }
            })

        }
    }

    class func getTripData(withTripID tripID: String, completionHandler: @escaping (JSON?) -> Void) {

        if let gtfsURL = gtfsDataURL {
            getJSONData(fromURL: "\(gtfsURL)/stop_times/trip/\(tripID)", completionHandler: completionHandler)
        } else {
            getGTFSDataURL({ (gtfsURL) in
                if let url = gtfsURL {
                    gtfsDataURL = url
                    getJSONData(fromURL: "\(url)/stop_times/trip/\(tripID)", completionHandler: completionHandler)
                } else {
                    completionHandler(nil)
                }
            })

        }
    }

    class func getGTFSDataURL(_ completionHandler: @escaping (String?) -> Void) {
        getJSONData(fromURL: Constants.API.GTFSInfoURL, completionHandler: { json in

            guard let json = json else {
                completionHandler(nil)
                return
            }

            guard let host = json["host"].string,
                let path = json["gtfspath"].string,
                let latest = json["latest"].string else {
                    completionHandler(nil)
                    return
            }

            let url = "http://\(host)\(path.replacingOccurrences(of: "\\/", with: "/"))/\(latest)"
            completionHandler(url)

        })
    }

    class func getJSONData(fromURL url: String, completionHandler: @escaping (JSON?) -> Void) {
        Alamofire.request(url, method: .get)
            .responseData { response in
                //				print(response.request)

                switch response.result {

                case .success(let data):
                    completionHandler(JSON(data: data))

                case .failure:
                    completionHandler(nil)
                }
        }
    }

    // Cancel Active (bus data) request, if still running
    class func cancelActiveBusDataRequest() {
        if requestActive {
            latestRequest?.cancel()
        }
    }
}
