//
//  EditProfileController.swift
//  Port of Peri Peri
//
//  Created by Muhammad Umar on 15/08/2019.
//  Copyright © 2019 Neberox Technologies. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD
import Alamofire

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var userDp  : UIImageView!

    var imagePicker = UIImagePickerController()
    var imagePicked: UIImage!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userDp.contentMode = .scaleAspectFill
        //userDp.layer.masksToBounds = true
        //userDp.layer.cornerRadius = 60
        //userDp.clipsToBounds = true
        
        self.imagePicker.delegate = self
    }
    
    @IBAction func camBtnPressed(_btn: UIButton) {
       
        self.view.endEditing(true)
        let prefStyle:UIAlertController.Style = UIAlertController.Style.actionSheet

        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: prefStyle)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler:{
            
            (alert: UIAlertAction!) -> Void in
            print("camera")
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
                self.imagePicker.sourceType = UIImagePickerController.SourceType.camera;
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else {
            }
        })
        
        let galleryAction = UIAlertAction(title: "Photo Library", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum){
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else {
            }
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(galleryAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func saveBtnPressed(_btn: UIButton){
        self.updateProfile()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        dismiss(animated: true, completion: nil)
        if (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) != nil
        {
            let img = (info[UIImagePickerController.InfoKey.originalImage] as! UIImage?)!.byFixingOrientation()
            self.imagePicked = Utilities.resizeImage(image: img, newWidth: 1024)
            self.userDp.image = self.imagePicked
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    func updateProfile() {
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let url = "https://www.abc.com"
        
        do{            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                if self.imagePicked != nil {
                    if let imageData = self.imagePicked.jpegData(compressionQuality: 1) {
                        multipartFormData.append(imageData, withName: "image", fileName: "image.png", mimeType: Utilities.getImageMimieType(data: imageData))
                    }
                }
            }, usingThreshold: UInt64.init(), to: url, method: .post, headers:[:]) { (encodingResult) in
                
                switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseString(completionHandler: { (response) in
                            MBProgressHUD.hide(for: self.view, animated: true)
                            if let data = Utilities.parseResponse(response: response, view: self) as? [String: Any] {
                                self.navigationController?.popViewController(animated: true)
                            }
                        })
                    
                case .failure(_):
                        MBProgressHUD.hide(for: self.view, animated: true)
                }
            }
        }catch {
            print(error)
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
}

extension UIImage {
    
    func byFixingOrientation(andResizingImageToNewSize newSize: CGSize? = nil) -> UIImage {
        
        guard let cgImage = self.cgImage else { return self }
        
        let orientation = self.imageOrientation
        guard orientation != .up else { return UIImage(cgImage: cgImage, scale: 1, orientation: .up) }
        
        var transform = CGAffineTransform.identity
        let size = newSize ?? self.size
        
        if (orientation == .down || orientation == .downMirrored) {
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
        }
        else if (orientation == .left || orientation == .leftMirrored) {
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        }
        else if (orientation == .right || orientation == .rightMirrored) {
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -(CGFloat.pi / 2))
        }
        
        if (orientation == .upMirrored || orientation == .downMirrored) {
            transform = transform.translatedBy(x: size.width, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
        }
        else if (orientation == .leftMirrored || orientation == .rightMirrored) {
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform calculated above.
        guard let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                                  bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0,
                                  space: cgImage.colorSpace!, bitmapInfo: cgImage.bitmapInfo.rawValue)
            else {
                return UIImage(cgImage: cgImage, scale: 1, orientation: orientation)
        }
        
        ctx.concatenate(transform)
        
        // Create a new UIImage from the drawing context
        switch (orientation) {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        
        return UIImage(cgImage: ctx.makeImage() ?? cgImage, scale: 1, orientation: .up)
    }
}
