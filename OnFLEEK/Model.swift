//
//  Model.swift
//  OnFLEEK
//
//  Created by KEEVIN MITCHELL on 12/18/15.
//  Copyright © 2015 beyond2021. All rights reserved.
//

import Foundation
import CloudKit
import CoreLocation

let PartyType = "Party"
let NoteType = "Note"

protocol ModelDelegate {
    func errorUpdating(error: NSError)
    func modelUpdated()
}

class Model {
    
    class func sharedInstance() -> Model {
        return modelSingletonGlobal
    }
    
    var delegate : ModelDelegate?
    
    var items = [Party]()
    let userInfo : UserInfo
    
    let container : CKContainer
    let publicDB : CKDatabase
    let privateDB : CKDatabase
    
    init() {
        container = CKContainer.defaultContainer() //1
        publicDB = container.publicCloudDatabase //2
        privateDB = container.privateCloudDatabase //3
        
        userInfo = UserInfo(container: container)
    }
    
    func refresh() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Establishment", predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.errorUpdating(error!)
                    print("error loading: \(error)")
                }
            } else {
                self.items.removeAll(keepCapacity: true)
                for record in results! {
                    let party = Party(record: record , database:self.publicDB)
                    self.items.append(party)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.modelUpdated()
                    print("")
                }
            }
        }
    }
    
    func party(ref: CKReference) -> Party! {
        let matching = items.filter {$0.record.recordID == ref.recordID}
        var e : Party!
        if matching.count > 0 {
            e = matching[0]
        }
        return e
    }
    
    //  func fetchEstablishments(location:CLLocation,
    //                           radiusInMeters:CLLocationDistance) {
    //    //replace this stub
    //    dispatch_async(dispatch_get_main_queue()) {
    //      self.delegate?.modelUpdated()
    //      print("model updated")
    //    }
    //  }
    //
    func fetchEstablishments(location:CLLocation,
        radiusInMeters:CLLocationDistance) {
            // 1
            let radiusInKilometers = radiusInMeters / 1000.0
            // 2
            let locationPredicate = NSPredicate(format: "distanceToLocation:fromLocation:(%K,%@) < %f",
                "Location",
                location,
                radiusInKilometers)
            // 3
            let query = CKQuery(recordType: PartyType,
                predicate:  locationPredicate)
            // 4
            publicDB.performQuery(query, inZoneWithID: nil) {
                results, error in
                if error != nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.delegate?.errorUpdating(error!)
                        return
                    }
                } else {
                    self.items.removeAll(keepCapacity: true)
                    for record in results!{
                        let establishment = Party(record: record , database: self.publicDB)
                        self.items.append(establishment)
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.delegate?.modelUpdated()
                        return
                    }
                }
            }
    }
    
    
    
    
    func fetchEstablishments(location:      CLLocation,
        radiusInMeters:CLLocationDistance,
        completion:    (results:[Party]!, error:NSError!) -> ()) {
            let radiusInKilometers = radiusInMeters / 1000.0 //1
            //Apple Campus location = 37.33182, -122.03118
            let location = CLLocation(latitude: 37.33182, longitude: -122.03118)
            
            let locationPredicate = NSPredicate(format: "distanceToLocation:fromLocation:(%K,%@) < %f",
                "Location",
                location,
                radiusInKilometers) //2
            let query = CKQuery(recordType: PartyType,
                predicate:  locationPredicate) //3
            publicDB.performQuery(query, inZoneWithID: nil) { //4
                results, error in
                var res = [Party]()
                if let records = results {
                    for record in records {
                        let establishment = Party(record: record , database:self.publicDB)
                        res.append(establishment)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    completion(results: res, error: error)
                }
            }
    }
    
    // #pragma mark - Notes
    
    func fetchNotes( completion : (notes : NSArray!, error : NSError!) -> () ) {
        let query = CKQuery(recordType: NoteType, predicate: NSPredicate(value: true))
        privateDB.performQuery(query, inZoneWithID: nil) { results, error in
            completion(notes: results, error: error)
        }
    }
    
    func fetchNote(establishment: Party,
        completion:(note: String!, error: NSError!) ->()) {
            //replace this stub
            completion(note: nil, error: nil)
    }
    
    func addNote(note: String,
        establishment: Party!,
        completion: (error : NSError!)->()) {
            
            //replace this stub
            completion(error: nil)
    }
}

let modelSingletonGlobal = Model()