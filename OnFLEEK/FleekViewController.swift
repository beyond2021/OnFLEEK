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
import MobileCoreServices //kUTTypeMovie

class FleekViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // Set up the cloudKit manager
    let cloudKitManager = AAPLCloudManager()
    
    // set up the name of the asset record
    var assetRecordName = " "
    
    //MARK: - Image
    
    var assetPreview =  UIImageView()
    
    @IBOutlet weak var assetPreviewContainer: UIView! {
        didSet{
            // When this is set I will put my image inside
            assetPreviewContainer.addSubview(assetPreview)
        }
        
    }
    
    
    
    func makeRoomForImage(){
        var extraHeight: CGFloat = 0
        if assetPreview.image?.aspectRatio > 0 {
            if let width = assetPreview.superview?.frame.size.width {
                let height = width / assetPreview.image!.aspectRatio
                extraHeight = height - assetPreview.frame.height
                assetPreview.frame = CGRect(x: 0, y: 0, width: width, height: height)
            } else {
                extraHeight = -assetPreview.frame.height
                assetPreview.frame = CGRectZero
            }
            preferredContentSize = CGSize(width: preferredContentSize.width, height: preferredContentSize.height + extraHeight)
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    
    
    // Do the upload to cloudKit
    @IBAction func uploadAction(sender: UIButton) {
        
        // CREATE THE PICKER
        // 1: IF I HAVE A PICKER
        if UIImagePickerController.isSourceTypeAvailable(.Camera){
            //SET MY PICKER'S SOURCETYPE TO BE THE CAMERA
            let picker = UIImagePickerController()
            picker.sourceType = .Camera
            // IF I WAS DOING VIDEO I WOULD CHECK THE MEDIA TYPES HERE.
            picker.mediaTypes = [kUTTypeImage as String]
            //SET ITS DELEGATE
            picker.delegate = self
            // LETS ALLOW EDITING
            picker.allowsEditing = true
            
            // PRESENT IT
            presentViewController(picker, animated: true, completion: nil)
            
        }
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
    
    
    //MARK:DELEGATE METHODS
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //THE IMAGE THE PICKED IS THE INFO OF THE DICTIONARY
        var image = info[UIImagePickerControllerEditedImage] as? UIImage // we want it as a uiimage because info dic is anyObject.
        
        if image == nil {
            //IF I COULDNT GET THE EDITED IMGAGE THEN I WILL TAKE THE  UNEDITED IMAGE
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        
        // NOW THAT I HAVE THE IMAGE I GOING TO SET MY IMAGEVIEW'S IMAGE TO THAT
        //  imageView.image = image
        //WE WILL THEN MAKE ROOM FOR IT
        // makeRoomForImage()
        // THEN WE ILL DISMISS
        saveAndUploadImageToiCloud(image!)
        
        //     dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveAndUploadImageToiCloud(image:UIImage?){
        
        // LETS PUT THIS ON A GLOBAL QUEUE
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            
            // IF WE CAN GET THAT IMAGE
            if let image = image {
                // THEN I WILL GET THE IMAGEDATA AS A JPEG
                if let imageData = UIImageJPEGRepresentation(image, 1.0){
                    // THEN WE WILL TURN THIS INTO NSDATA / OPPOSITE WOULD BE NSDATACONTENTSFORURL
                    //1: GET THE FILE MANAGER
                    //    let fileManager = NSFileManager.defaultManager() // WE ARE IN THE MAIN THREAD BUT JUST INCASE WE ARE NOT IN THE MAIN THREAD.
                    
                    let fileManager = NSFileManager()
                    //WHERE R WE GOING TO SAVE IT. LETS USE THE DOCUMENTS DIRECTORY
                    if let docsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as? NSURL{
                        //NOW WE HAVE THE DOCUMENTSDIRECTORY WE NEED A UNIQUE NAME FOR THE PHOTO WE TOOK
                        let unique = NSDate.timeIntervalSinceReferenceDate() //UNIQUE BECAUSE U CANT TAKE 2 PHOTOS AT THE SAME INSTANCE OF TIME.
                        //NEXT WE SET THE URL FOR MY PHOTO
                        let url = docsDir.URLByAppendingPathComponent("\(unique)") //HERE WECREATE A STRING FROM THE UNIQUE TIME
                        
                        //IF I CAN GET THE PATH TO THE URL
                        if let path = (url.absoluteString) as? String {
                            
                            if imageData.writeToURL(url, atomically: true){
                                // if I can seccessfully do this the I will upload it to icloud
                                
                                
                                self.cloudKitManager.uploadAssetWithURL(url, completionHandler: { (record ) -> Void in
                                    
                                    if ((record == nil)) {
                                        print("Handle this gracefully in your own app.")
                                        
                                    } else {
                                        self.assetRecordName = record.recordID.recordName
                                        let alert = UIAlertController(title: "Glamor Shot!!", message: "Successfully Uploaded", preferredStyle: .Alert)
                                        
                                        let action = UIAlertAction(title: "OK", style: .Default, handler: { (act) -> Void in
                                            self.dismissViewControllerAnimated(true, completion: nil)
                                        })
                                        
                                        alert.addAction(action)
                                        self.presentViewController(alert, animated: true, completion: nil)
                                        
                                    }
                                    
                                })
                                self.dismissViewControllerAnimated(true, completion: nil)
                                
                                
                            }
                            
                            
                        }
                        
                        
                    }
                    
                    
                }
                
                
            }
            
        }
        
    }
    
    
    
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
        picker.delegate = nil
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
                
                if   let image = UIImage(contentsOfFile: photoAsset.fileURL.path!) {
                    //  fixImageOrientation(image)
                    
                    self.assetPreview.image = image
                    self.makeRoomForImage()
                }
                
            })
            
            
        }
    }
}

extension UIImage {
    var aspectRatio: CGFloat {
        return size.height != 0 ? size.width / size.height : 0
        
    }
    
}


