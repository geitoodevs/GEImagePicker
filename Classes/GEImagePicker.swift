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
    case ok
    case cancelled
    case noSource
    case notPermission
}

enum GEImagePickerSource {
    case camera
    case savedPhotosAlbum
    case photoLibrary
}

class GEImagePicker: NSObject {
    
    var callback:((_ image: UIImage?,_ status : GEImagePickerStatus)->Void)?
    
    // MARK - Public Methods
    
    class func pickImageActionSheet(_ whereViewController : UIViewController,
                                               editMode : Bool,
                                             completion : @escaping (_ image: UIImage?,
                                                 _ status : GEImagePickerStatus)->()) {
                                                    
                            let actionSheet = UIAlertController(title: "Picture Selection",
                                message: "Select the source",
                                preferredStyle: UIAlertControllerStyle.actionSheet)
                            
                            actionSheet.addAction(UIAlertAction(title: "Camera",
                                style: UIAlertActionStyle.default,
                                handler: { (action) -> Void in
                                
                                self.pickImage(GEImagePickerSource.camera,
                                    whereViewController: whereViewController,
                                    editMode: editMode,
                                    completion: completion)
                                
                            }))
            
                            actionSheet.addAction(UIAlertAction(title: "Saved Photos Album",
                                style: UIAlertActionStyle.default,
                                handler: { (action) -> Void in
                                    
                                self.pickImage(GEImagePickerSource.savedPhotosAlbum,
                                    whereViewController: whereViewController,
                                    editMode: editMode,
                                    completion: completion)
                                
                            }))
                                                    
                            actionSheet.addAction(UIAlertAction(title: "Photo Library",
                                style: UIAlertActionStyle.default,
                                handler: { (action) -> Void in
                                    
                                    self.pickImage(GEImagePickerSource.photoLibrary,
                                        whereViewController: whereViewController,
                                        editMode: editMode,
                                        completion: completion)
                                    
                            }))
                            actionSheet.addAction(UIAlertAction(title: "Cancel",
                                style: UIAlertActionStyle.destructive,
                                handler: { (action) -> Void in
                                    
                                    completion(nil, GEImagePickerStatus.cancelled)
                                    
                            }))
                                                    
                            whereViewController.present(actionSheet,
                                animated: true, completion: nil)
    }
    
    
    class func pickImage(_ source : GEImagePickerSource,
            whereViewController : UIViewController,
                       editMode : Bool,
                     completion : @escaping (_ image: UIImage?,
                         _ status : GEImagePickerStatus)->()) {
                            
                            var sourceType : UIImagePickerControllerSourceType
                            
                            
                            if source == GEImagePickerSource.camera {
                                sourceType = UIImagePickerControllerSourceType.camera;
                            }else if source == GEImagePickerSource.photoLibrary {
                                sourceType = UIImagePickerControllerSourceType.photoLibrary;
                            }else {
                                sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum;
                            }
                            
                            if UIImagePickerController.isSourceTypeAvailable(sourceType) == false {
                                completion(nil, GEImagePickerStatus.noSource);
                            }
                            
                            if (sourceType == UIImagePickerControllerSourceType.camera){
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
                            
    fileprivate class func showPicker(_ type : UIImagePickerControllerSourceType,
                             whe : UIViewController,
                            edit : Bool,
                            comp : @escaping (_ image: UIImage?,
                            _ stat : GEImagePickerStatus)->()) {
                            
                            let delegate : GEImagePicker = GEImagePicker()
                            delegate.callback = comp
                                
                            let picker = UIImagePickerController()
                            picker.delegate = delegate
                            picker.allowsEditing = edit
                            picker.sourceType = type
                            whe.present(picker, animated: true, completion: nil)
                            
                            var aoKey = ""
                            objc_setAssociatedObject(picker,
                                &aoKey,
                                delegate,
                                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

    }
    
    fileprivate class func checkCamera(_ completion: @escaping (_ success : Bool) ->()) {
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if authStatus == AVAuthorizationStatus.authorized {
            completion(true)
        }
        else if authStatus == AVAuthorizationStatus.notDetermined {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo,
                completionHandler: { (granted : Bool) -> Void in
                completion(granted)
            })
        }
        else{
            completion(false)
        }

    }
    
    fileprivate class func checkAlbum(_ completion: @escaping (_ success : Bool) ->()) {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        
        if authStatus == PHAuthorizationStatus.authorized {
            completion(true)
        }else if authStatus == PHAuthorizationStatus.notDetermined {
            
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                
                if status == PHAuthorizationStatus.authorized {
                    completion(true)
                }else{
                    completion(false)
                }
            })
            
        }else {
            completion(false)
        }
    
    }
    
    fileprivate class func notPermission(_ controller : UIViewController, completion : @escaping (_ image: UIImage?,
        _ status : GEImagePickerStatus)->()){
    
        let alert = UIAlertController(title: "Attention",
            message: "You don't have permission for accessing to Camera/Library\nGo to settings in order to let the app use them.",
            preferredStyle: UIAlertControllerStyle.alert)
        
        
        alert.addAction(UIAlertAction(title: "Cancel",
            style: UIAlertActionStyle.cancel,
            handler: { (action) -> Void in
                
                completion(nil, GEImagePickerStatus.notPermission)
        }))
        alert.addAction(UIAlertAction(title: "Go",
            style: UIAlertActionStyle.default,
            handler: { (action) -> Void in
                
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))
        
        controller.present(alert, animated: true, completion: nil)

    }
    
}


extension GEImagePicker : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController,
        didFinishPickingImage image: UIImage,
        editingInfo: [String : AnyObject]?) {
        
        picker.dismiss(animated: true) { () -> Void in
            
            if self.callback != nil {
                
                var finalImage = editingInfo![UIImagePickerControllerEditedImage] as? UIImage
                if finalImage == nil {
                    finalImage = editingInfo![UIImagePickerControllerOriginalImage] as? UIImage
                }
                
                self.callback!(finalImage!,GEImagePickerStatus.ok)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true) { () -> Void in
            
            if self.callback != nil {
                self.callback!(nil,GEImagePickerStatus.cancelled)
            }
        }
    }
    
}
