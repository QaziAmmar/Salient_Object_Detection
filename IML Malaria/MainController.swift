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

class MainController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var userDp  : UIImageView!
//    @IBOutlet weak var predictionLbl: UILabel!
    @IBOutlet weak var cellCountLbl: UILabel!
    //    @IBOutlet weak var confidanceLbl: UILabel!
    @IBOutlet weak var cellCount: UILabel!
    
    var pressButton = UIButton()
    
    var imagePicker = UIImagePickerController()
    var imagePicked: UIImage!
    var imageModel: ImagesModel!
    var imagePoints: [ImagePoint]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker.delegate = self
        cellCountLbl.isHidden = true
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
                //                self.imagePicker.allowsEditing = true
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
    
    @IBAction func countCellBtn(_ sender: UIButton) {
        countCells()
    }
    
    @IBAction func CheckSingleCell(_ sender: UIButton) {
        checkMalaria()
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true, completion: nil)
        if (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) != nil
        {
            let img = (info[UIImagePickerController.InfoKey.originalImage] as! UIImage?)!.byFixingOrientation()
            //            self.imagePicked = Utilities.resizeImage(image: img, newWidth: 1024)
            self.imagePicked = img
            self.userDp.image = self.imagePicked
            
            
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// API Extension.
extension MainController {
    
    
    func checkMalaria()  {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let url = "http://192.168.1.5:8000/api/check_malaria/"
        
        do{
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                if self.imagePicked != nil {
                    if let imageData = self.imagePicked.jpegData(compressionQuality: 0) {
                        multipartFormData.append(imageData, withName: "file", fileName: "image.png", mimeType: Utilities.getImageMimieType(data: imageData))
                    }
                }
            }, usingThreshold: UInt64.init(), to: url, method: .post, headers:[:]) { (encodingResult) in
                
                switch encodingResult {
                case .success(let upload, _, _):
                    
                    upload.responseData(completionHandler: { (response) in
                        MBProgressHUD.hide(for: self.view, animated: true)
                        
                        switch response.result {
                        case .success(let value):
                            
                            let decoder = JSONDecoder()
                            do{
                                _ = try decoder.decode(MalariaPrediction.self, from: value)
                                self.updateLbl(image: self.imagePicked)
                                
                            }catch let error {
                                print(error)
                            }
                            
                        case .failure(let error):
                            print(error)
                        }
                        
                    })
                    
                case .failure(_):
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            }
        }
    }
    
    func countCells() {
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let url = "http://192.168.1.5:8000/api/test/"
        
        do{
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                if self.imagePicked != nil {
                    if let imageData = self.imagePicked.jpegData(compressionQuality: 0) {
                        multipartFormData.append(imageData, withName: "file", fileName: "image.png", mimeType: Utilities.getImageMimieType(data: imageData))
                    }
                }
            }, usingThreshold: UInt64.init(), to: url, method: .post, headers:[:]) { (encodingResult) in
                
                switch encodingResult {
                case .success(let upload, _, _):
                    
                    upload.responseData(completionHandler: { (response) in
                        MBProgressHUD.hide(for: self.view, animated: true)
                        
                        switch response.result {
                        case .success(let value):
                            
                            let decoder = JSONDecoder()
                            do{
                                let FULLResponse = try
                                    decoder.decode(ImagesModel.self, from: value)
                                self.updateImage(model: FULLResponse)
                                
                                
                            }catch let error {
                                print(error)
                            }
                            
                        case .failure(let error):
                            print(error)
                        }
                    })
                    
                case .failure(_):
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            }
        }
    }
    
    func updateLbl(image: UIImage) {

        let imageSize = image.size
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        let context = UIGraphicsGetCurrentContext()
        image.draw(at: CGPoint.zero)
        let tempPoint = self.imagePoints[10...15]
        for point in tempPoint {
            
            
            let rectangle = CGRect(x: point.x!, y: point.y!, width: point.w!, height: point.h!)
            
            context!.setStrokeColor(UIColor.red.cgColor)
            context!.setLineWidth(2)
            context?.setFillColor(red: 255, green: 255, blue: 255, alpha: 0)
            context!.addRect(rectangle)
            context!.drawPath(using: .stroke)
            
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        userDp.image = newImage
        
    }
    
    
    func updateImage(model: ImagesModel) {
        let image = userDp.image
        let imageSize = image?.size
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(imageSize!, false, scale)
        let context = UIGraphicsGetCurrentContext()
        image?.draw(at: CGPoint.zero)
        self.imagePoints = (model.data?.imagePoints!)!
        for point in (model.data?.imagePoints!)! {
            let rectangle = CGRect(x: point.x!, y: point.y!, width: point.w!, height: point.h!)
            
            context!.setStrokeColor(UIColor.black.cgColor)
            context!.setLineWidth(2)
            context?.setFillColor(red: 255, green: 255, blue: 255, alpha: 0)
            context!.addRect(rectangle)
            context!.drawPath(using: .stroke)
            
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        userDp.image = newImage
        cellCountLbl.isHidden = false
        cellCount.text = String(describing: model.data?.imagePoints?.count ?? 0)
        
        
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
