//
//  Photo.swift
//  OnFLEEK
//
//  Created by KEEVIN MITCHELL on 12/29/15.
//  Copyright © 2015 beyond2021. All rights reserved.
//

import Foundation
import CloudKit

struct Photo {
    let fPhoto : CKAsset
    
    init(fPhoto : CKAsset, database: CKDatabase) {
        self.fPhoto = fPhoto
//        self.database = database
//        
//        self.name = record.objectForKey("Name") as! String
//        self.location = record.objectForKey("Location") as! CLLocation
    }
    
    
}
