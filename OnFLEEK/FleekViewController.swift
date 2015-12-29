//
//  FleekViewController.swift
//  OnFLEEK
//
//  Created by KEEVIN MITCHELL on 12/29/15.
//  Copyright © 2015 beyond2021. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class FleekViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // Set up the cloudKit manager
    let cloudKitManager = AAPLCloudManager()
    
    // Set up the view for the fleek array
    @IBOutlet weak var assetPreview: UIImageView!
    
    // set up the name of the asset record
    var assetRecordName = " "
    
    // Do the upload to cloudKit
    @IBAction func uploadAction(sender: UIButton) {
        
//        dispatch_async(dispatch_get_main_queue(), {
//            let imagePicker: UIImagePickerController = UIImagePickerController();
//            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
//            imagePicker.mediaTypes = [kUTTypeImage];
//            imagePicker.allowsEditing = false;
//            imagePicker.delegate = self;
//            
//            if(UIDevice.currentDevice().userInterfaceIdiom == .Pad){ // on a tablet, the image picker is supposed to be in a popover
//                let popRect: CGRect = buttonRect;
//                let popover: UIPopoverController = UIPopoverController(contentViewController: imagePicker);
//                popover.presentPopoverFromRect(popRect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Up, animated: true);
//            }else{
//                self.presentViewController(imagePicker, animated: true, completion: nil);
//            }
//        });
        
        
        
        
        
        
        
        
        let imagePicker = UIImagePickerController()
        
        // TODO GET FOR CAMERA AVAILABILITY
        
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.delegate = self
        imagePicker.cameraCaptureMode = .Photo
        
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .Alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.Default,
            handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC,
            animated: true,
            completion: nil)
    }
    // Picker delegate Method
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            // retrieve the image and resize it down
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            var newSize = CGSizeMake(512, 512)
            
            if (image.size.width > image.size.height) {
                newSize.height = round(newSize.width * image.size.height / image.size.width);
            } else {
                newSize.width = round(newSize.height * image.size.width / image.size.height);
            }
            
            // Size up the image
            UIGraphicsBeginImageContext(newSize)
            
            image.drawAsPatternInRect(CGRectMake(0, 0, newSize.width, newSize.height))
            
            let data = UIImageJPEGRepresentation(UIGraphicsGetImageFromCurrentImageContext(), 0.75)
            
            UIGraphicsEndImageContext()
            
            
            
            do {
            
            // write the image out to a cache file 
            let cachesDirectory = try NSFileManager.defaultManager().URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
                
                let temporaryName = NSUUID().UUIDString.stringByAppendingString(".jpeg")
                
                let writePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("jpeg")
                
                
                let localURL = cachesDirectory.URLByAppendingPathComponent(temporaryName) as NSURL
                
                data?.writeToURL(localURL, atomically: true)
                
       
                self.cloudKitManager.uploadAssetWithURL(localURL, completionHandler: { (record ) -> Void in
                    
                    if ((record == nil)) {
                       print("Handle this gracefully in your own app.")
                        
                    } else {
                       self.assetRecordName = record.recordID.recordName
                        let alert = UIAlertController(title: "CloudKit Catalog", message: "Successfully Uploaded", preferredStyle: .Alert)
                        
                        let action = UIAlertAction(title: "OK", style: .Default, handler: { (act) -> Void in
                            self.dismissViewControllerAnimated(true, completion: nil)
                        })
                        
                        alert.addAction(action)
                        self.presentViewController(alert, animated: true, completion: nil)
                                         
                    }
                    
               })
                
               self.dismissViewControllerAnimated(true, completion: nil)
                
                
            } catch {
                
               print("There was a cashe error")
            }
            
            
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBOutlet weak var downloadPhotos: UIButton!
    
    @IBAction func downLoad(sender: UIButton) {
        
        
        if assetRecordName.isEmpty  {
            let alert = UIAlertController(title: "OnFleek!!", message: "Upload an asset to retrieve it.", preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: { (act) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
            
            
        } else {
            cloudKitManager.fetchRecordWithID(assetRecordName, completionHandler: { (record) -> Void in
                let photoAsset = record[PhotoAssetField] as! CKAsset
                
                let image = UIImage(contentsOfFile: photoAsset.fileURL.path!)
                
                self.assetPreview.image = image
            
            
            })
            
            
        }
        
        
        
        
        
        
        
    }
}
