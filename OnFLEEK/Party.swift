//
//  Party.swift
//  OnFLEEK
//
//  Created by KEEVIN MITCHELL on 12/18/15.
//  Copyright © 2015 beyond2021. All rights reserved.
//

import Foundation
import CloudKit
import MapKit

struct PartyLocation : OptionSetType, BooleanType {
    var rawValue: UInt = 0
    var boolValue:Bool {
        get {
            return self.rawValue != 0
        }
    }
    init(rawValue: UInt) { self.rawValue = rawValue }
    init(nilLiteral: ()) { self.rawValue = 0 }
    func toRaw() -> UInt { return self.rawValue }
    static func convertFromNilLiteral() -> PartyLocation { return .None}
    static func fromRaw(raw: UInt) -> PartyLocation? { return self.init(rawValue: raw) }
    static func fromMask(raw: UInt) -> PartyLocation { return self.init(rawValue: raw) }
    static var allZeros: PartyLocation { return self.init(rawValue: 0) }
    
    static var None: PartyLocation   { return self.init(rawValue: 0) }      //0
    static var Mens: PartyLocation   { return self.init(rawValue: 1 << 0) } //1
    static var Womens: PartyLocation { return self.init(rawValue: 1 << 1) } //2
    static var Family: PartyLocation { return self.init(rawValue: 1 << 2) } //4
    
    func images() -> [UIImage] {
        var images = [UIImage]()
        if self.intersect(.Mens) {
            images.append(UIImage(named: "man")!)
        }
        if self.intersect(.Womens) {
            images.append(UIImage(named: "woman")!)
        }
        
        return images
    }
}

func == (lhs: PartyLocation, rhs: PartyLocation) -> Bool     { return lhs.rawValue == rhs.rawValue }
func | (lhs: PartyLocation, rhs: PartyLocation) -> PartyLocation { return PartyLocation(rawValue: lhs.rawValue | rhs.rawValue) }
func & (lhs: PartyLocation, rhs: PartyLocation) -> PartyLocation { return PartyLocation(rawValue: lhs.rawValue & rhs.rawValue) }
func ^ (lhs: PartyLocation, rhs: PartyLocation) -> PartyLocation { return PartyLocation(rawValue: lhs.rawValue ^ rhs.rawValue) }


struct SeatingType : OptionSetType, BooleanType {
    var rawValue: UInt = 0
    var boolValue:Bool {
        get {
            return self.rawValue != 0
        }
    }
    init(rawValue: UInt) { self.rawValue = rawValue }
    init(nilLiteral: ()) { self.rawValue = 0 }
    func toRaw() -> UInt { return self.rawValue }
    static func convertFromNilLiteral() -> SeatingType { return .None}
    static func fromRaw(raw: UInt) -> SeatingType? { return self.init(rawValue: raw) }
    static func fromMask(raw: UInt) -> SeatingType { return self.init(rawValue: raw) }
    static var allZeros: SeatingType { return self.init(rawValue: 0) }
    
    static var None:      SeatingType { return self.init(rawValue: 0) }      //0
    static var Booster:   SeatingType { return self.init(rawValue: 1 << 0) } //1
    static var HighChair: SeatingType { return self.init(rawValue: 1 << 1) } //2
    
    func images() -> [UIImage] {
        var images = [UIImage]()
        if self.intersect(.Booster) {
            images.append(UIImage(named: "booster")!)
        }
        if self.intersect(.HighChair) {
            images.append(UIImage(named: "highchair")!)
        }
        
        return images
    }
}

func == (lhs: SeatingType, rhs: SeatingType) -> Bool     { return lhs.rawValue == rhs.rawValue }
func | (lhs: SeatingType, rhs: SeatingType) -> SeatingType { return SeatingType(rawValue: lhs.rawValue | rhs.rawValue) }
func & (lhs: SeatingType, rhs: SeatingType) -> SeatingType { return SeatingType(rawValue: lhs.rawValue & rhs.rawValue) }
func ^ (lhs: SeatingType, rhs: SeatingType) -> SeatingType { return SeatingType(rawValue: lhs.rawValue ^ rhs.rawValue) }

class Party : NSObject, MKAnnotation {
    
    var record : CKRecord!
    var name : String!
    var location : CLLocation!
    weak var database : CKDatabase!
    
    var assetCount = 0
    
    var healthyChoice : Bool {
        get {
            //  return record.objectForKey("HealthyOption")
            
            if record.objectForKey("HealthyOption") != nil {
                return true
            } else {
                return false
            }
        }
    }
    
    var kidsMenu: Bool {
        get {
            // return record.objectForKey("KidsMenu")
            if record.objectForKey("KidsMenu") != nil {
                return true
            } else {
                return false
            }
            
            
        }
    }
    
    /*
    /Users/keevinmitchell/Desktop/BabiFud-Starter/BabiFud/Establishment.swift:115:19: Value of type 'CKRecordValue?' has no member 'boolValue'
    return record.objectForKey("KidsMenu").boolValue*/
    
    
    
    init(record : CKRecord, database: CKDatabase) {
        self.record = record
        self.database = database
        
        self.name = record.objectForKey("Name") as! String
        self.location = record.objectForKey("Location") as! CLLocation
    }
    
    func fetchRating(completion: (rating: Double, isUser: Bool) -> ()) {
        Model.sharedInstance().userInfo.userID() { userRecord, error in
            self.fetchRating(userRecord, completion: completion)
        }
    }
    
    func fetchRating(userRecord: CKRecordID!, completion: (rating: Double, isUser: Bool) -> ()) {
        //REPLACE THIS STUB
        completion(rating: 0, isUser: false)
    }
    
    func fetchNote(completion: (note: String!) -> ()) {
        Model.sharedInstance().fetchNote(self) { note, error in
            completion(note: note)
        }
    }
    
    func fetchPhotos(completion:(assets: [CKRecord]!)->()) {
        let predicate = NSPredicate(format: "Establishment == %@", record)
        let query = CKQuery(recordType: "EstablishmentPhoto", predicate: predicate);
        //Intermediate Extension Point - with cursors
        database.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                self.assetCount = results!.count
            }
            completion(assets: results! )
        }
    }
    
    func changingTable() -> PartyLocation {
        let changingTable = record?.objectForKey("ChangingTable") as? NSNumber
        var val:UInt = 0;
        if let changingTableNum = changingTable {
            val = changingTableNum.unsignedLongValue
        }
        return PartyLocation(rawValue: val)
    }
    
    func seatingType() -> SeatingType {
        let seatingType = record?.objectForKey("SeatingType") as? NSNumber
        var val:UInt = 0;
        if let seatingTypeNum = seatingType {
            val = seatingTypeNum.unsignedLongValue
        }
        return SeatingType(rawValue: val)
    }
    
    //  func loadCoverPhoto(completion:(photo: UIImage!) -> ()) {
    //    //replace this stub
    //    completion(photo: nil)
    //  }
    func loadCoverPhoto(completion:(photo: UIImage!) -> ()) {
        // 1
        dispatch_async(
            dispatch_get_global_queue(
                DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)){
                    var image: UIImage!
                    // 2
                    if let asset = self.record.objectForKey("CoverPhoto") as? CKAsset {
                        // 3
                        if let url = asset.fileURL as? NSURL{
                            let imageData = NSData(contentsOfFile: url.path!)!
                            // 4
                            image = UIImage(data: imageData) 
                        }
                    }
                    // 5
                    completion(photo: image) 
        }
    }
    
    
    //MARK: - map annotation
    
    var coordinate : CLLocationCoordinate2D {
        get {
            return location.coordinate
        }
    }
    var title : String? {
        get {
            return name
        }
    }
    
    
}
