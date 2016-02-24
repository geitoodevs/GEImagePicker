//
//  GEImagePicker.swift
//  SwiftPlayGround
//
//  Created by Miguel Angel Rodriguez on 23/02/16.
//  Copyright © 2016 Miguel Angel Rodriguez. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

enum GEImagePickerStatus {
    case OK
    case Cancelled
    case NoSource
    case NotPermission
}

enum GEImagePickerSource {
    case Camera
    case SavedPhotosAlbum
    case PhotoLibrary
}

class GEImagePicker: NSObject {
    
    var callback:((image: UIImage?,status : GEImagePickerStatus)->Void)?
    
    // MARK - Public Methods
    
    class func pickImageActionSheet(whereViewController : UIViewController,
                                               editMode : Bool,
                                             completion : (image: UIImage?,
                                                 status : GEImagePickerStatus)->()) {
                                                    
                            let actionSheet = UIAlertController(title: "Picture Selection",
                                message: "Select the source",
                                preferredStyle: UIAlertControllerStyle.ActionSheet)
                            
                            actionSheet.addAction(UIAlertAction(title: "Camera",
                                style: UIAlertActionStyle.Default,
                                handler: { (action) -> Void in
                                
                                self.pickImage(GEImagePickerSource.Camera,
                                    whereViewController: whereViewController,
                                    editMode: editMode,
                                    completion: completion)
                                
                            }))
            
                            actionSheet.addAction(UIAlertAction(title: "Saved Photos Album",
                                style: UIAlertActionStyle.Default,
                                handler: { (action) -> Void in
                                    
                                self.pickImage(GEImagePickerSource.SavedPhotosAlbum,
                                    whereViewController: whereViewController,
                                    editMode: editMode,
                                    completion: completion)
                                
                            }))
                                                    
                            actionSheet.addAction(UIAlertAction(title: "Photo Library",
                                style: UIAlertActionStyle.Default,
                                handler: { (action) -> Void in
                                    
                                    self.pickImage(GEImagePickerSource.PhotoLibrary,
                                        whereViewController: whereViewController,
                                        editMode: editMode,
                                        completion: completion)
                                    
                            }))
                            actionSheet.addAction(UIAlertAction(title: "Cancel",
                                style: UIAlertActionStyle.Destructive,
                                handler: { (action) -> Void in
                                    
                                    completion(image: nil, status: GEImagePickerStatus.Cancelled)
                                    
                            }))
                                                    
                            whereViewController.presentViewController(actionSheet,
                                animated: true, completion: nil)
    }
    
    
    class func pickImage(source : GEImagePickerSource,
            whereViewController : UIViewController,
                       editMode : Bool,
                     completion : (image: UIImage?,
                         status : GEImagePickerStatus)->()) {
                            
                            var sourceType : UIImagePickerControllerSourceType
                            
                            
                            if source == GEImagePickerSource.Camera {
                                sourceType = UIImagePickerControllerSourceType.Camera;
                            }else if source == GEImagePickerSource.PhotoLibrary {
                                sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
                            }else {
                                sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
                            }
                            
                            if UIImagePickerController.isSourceTypeAvailable(sourceType) == false {
                                completion(image: nil, status: GEImagePickerStatus.NoSource);
                            }
                            
                            if (sourceType == UIImagePickerControllerSourceType.Camera){
                                self.checkCamera({ (success) -> () in
                                    
                                    if success == true {
                                        
                                        self.showPicker(sourceType,
                                            whe: whereViewController,
                                            edit : editMode,
                                            comp: completion)
                                    }else{
                                        self.notPermission(whereViewController,completion: completion);
                                    }
                                    
                                })
                            }else{
                                
                                self.checkAlbum({ (success) -> () in
                                    
                                    if success == true {
                                        
                                        self.showPicker(sourceType,
                                            whe: whereViewController,
                                            edit : editMode,
                                            comp: completion)
                                    }else{
                                        self.notPermission(whereViewController,completion: completion);
                                    }
                                    
                                })
                                
                            }
    }
    
    
    // MARK - Private Methods
                            
    private class func showPicker(type : UIImagePickerControllerSourceType,
                             whe : UIViewController,
                            edit : Bool,
                            comp : (image: UIImage?,
                            stat : GEImagePickerStatus)->()) {
                            
                            let delegate : GEImagePicker = GEImagePicker()
                            delegate.callback = comp
                                
                            let picker = UIImagePickerController()
                            picker.delegate = delegate
                            picker.allowsEditing = edit
                            picker.sourceType = type
                            whe.presentViewController(picker, animated: true, completion: nil)
                            
                            var aoKey = ""
                            objc_setAssociatedObject(picker,
                                &aoKey,
                                delegate,
                                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

    }
    
    private class func checkCamera(completion: (success : Bool) ->()) {
        let authStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        if authStatus == AVAuthorizationStatus.Authorized {
            completion(success: true)
        }
        else if authStatus == AVAuthorizationStatus.NotDetermined {
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo,
                completionHandler: { (granted : Bool) -> Void in
                completion(success: granted)
            })
        }
        else{
            completion(success: false)
        }

    }
    
    private class func checkAlbum(completion: (success : Bool) ->()) {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        
        if authStatus == PHAuthorizationStatus.Authorized {
            completion(success: true)
        }else if authStatus == PHAuthorizationStatus.NotDetermined {
            
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                
                if status == PHAuthorizationStatus.Authorized {
                    completion(success: true)
                }else{
                    completion(success: false)
                }
            })
            
        }else {
            completion(success: false)
        }
    
    }
    
    private class func notPermission(controller : UIViewController, completion : (image: UIImage?,
        status : GEImagePickerStatus)->()){
    
        let alert = UIAlertController(title: "Attention",
            message: "You don't have permission for accessing to Camera/Library\nGo to settings in order to let the app use them.",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        
        alert.addAction(UIAlertAction(title: "Cancel",
            style: UIAlertActionStyle.Cancel,
            handler: { (action) -> Void in
                
                completion(image: nil, status: GEImagePickerStatus.NotPermission)
        }))
        alert.addAction(UIAlertAction(title: "Go",
            style: UIAlertActionStyle.Default,
            handler: { (action) -> Void in
                
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }))
        
        controller.presentViewController(alert, animated: true, completion: nil)

    }
    
}


extension GEImagePicker : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingImage image: UIImage,
        editingInfo: [String : AnyObject]?) {
        
        picker.dismissViewControllerAnimated(true) { () -> Void in
            
            if self.callback != nil {
                
                var finalImage = editingInfo![UIImagePickerControllerEditedImage] as? UIImage
                if finalImage == nil {
                    finalImage = editingInfo![UIImagePickerControllerOriginalImage] as? UIImage
                }
                
                self.callback!(image: finalImage!,status: GEImagePickerStatus.OK)
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        picker.dismissViewControllerAnimated(true) { () -> Void in
            
            if self.callback != nil {
                self.callback!(image: nil,status: GEImagePickerStatus.Cancelled)
            }
        }
    }
    
}
