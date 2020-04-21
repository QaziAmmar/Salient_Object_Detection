//
//  Utilities.swift
//  Cupz
//
//  Created by Muhammad Umar on 20/11/2018.
//  Copyright © 2018 Neberox Technologies. All rights reserved.
//

import UIKit
import CommonCrypto
import CoreLocation
import Alamofire

class Utilities: NSObject {
    
    public static func getImageMimieType(data:Data) -> String
    {
        let array = [UInt8](data)
        var ext: String = ""
        
        switch (array[0]) {
        case 0xFF:
            ext = "image/jpg"
        case 0x89:
            ext = "image/png"
        case 0x47:
            ext = "image/gif"
        case 0x49, 0x4D :
            ext = "image/tiff"
        default:
            ext = "image/unknown"
        }
        
        return ext
    }
    
    public static func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage?
    {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    public static func parseResponse(response: DataResponse<String>, view: UIViewController?) -> Any {
        
        if let value = response.value{
            
            if let dict = Utilities.convertToDictionary(text: value) {
                return dict
            }else{
                Utilities.showErrorAlert(errorMessage: "It seems server is down, Please try again later", withView: view)
            }
        }
        else{
            Utilities.showErrorAlert(errorMessage: "It seems server is down, Please try again later", withView: view)
        }
        
        return ""
    }
    
    public static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
            }
        }
        return nil
    }
    

    public static func isEmailValid(email: String) -> Bool {

        //let stricterFilter = true
        //let laxString            = ".+@.+\\.[A-Za-z]{2}[A-Za-z]*"
        //let emailRegex = stricterFilter ? stricterFilterString : laxString;        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest : NSPredicate = NSPredicate.init(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    public static func isStringAnInt(string: String) -> Bool {
        return Int(string) != nil
    }
    
    public static func encryptMD5(string: String) -> String
    {
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        let md5Hex =  digestData.map { String(format: "%02hhx", $0) }.joined()
        return md5Hex
    }
    
    public static func generateRandomImageName() -> String
    {
        return encryptMD5(string: String(Date.init().timeIntervalSince1970));
    }
    
    public static func isPhoneValid(phone: String) -> Bool
    {
        return true
    }
    
    public static func showErrorAlert(errorMessage: String, withView viewCtrl:UIViewController?)
    {
        guard let _ = viewCtrl else {
            return
        }
        let alert = UIAlertController(title: "Oops!", message: errorMessage, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            
        }))
        
        viewCtrl!.present(alert, animated: true, completion: nil)
    }
    
    public static func showAlert(title: String, errorMessage: String, withView viewCtrl:UIViewController?)
    {
        guard let _ = viewCtrl else {
            return
        }
        
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            
        }))
        
        viewCtrl!.present(alert, animated: true, completion: nil)
    }
    
}


