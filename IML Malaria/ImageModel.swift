//
//  ApiManager.swift
//  IML Malaria
//
//  Created by Qazi Ammar Arshad on 25/03/2020.
//  Copyright © 2020 Neberox Technologies. All rights reserved.
//

import Foundation
import Alamofire

//class APIManager {
//
//
//    func updateProfile(imagePicked : UIImage) {
//        
//        //MBProgressHUD.showAdded(to: self.view, animated: true)
//        let url = "http://192.168.1.3:8000/api/test/"
//
//        do{
//            Alamofire.upload(multipartFormData: { (multipartFormData) in
//
//                if let imageData = imagePicked.jpegData(compressionQuality: 1) {
//                    multipartFormData.append(imageData, withName: "file", fileName: "image.png", mimeType: Utilities.getImageMimieType(data: imageData))
//                }
//
//            }, usingThreshold: UInt64.init(), to: url, method: .post, headers:[:]) { (encodingResult) in
//
//                switch encodingResult {
//                case .success(let upload, _, _):
//
//                    upload.responseData(completionHandler: { (response) in
//                        //MBProgressHUD.hide(for: self.view, animated: true)
//
//                        switch response.result {
//                        case .success(let value):
//
//                            let decoder = JSONDecoder()
//                            do{
//                                let FULLResponse = try
//                                    decoder.decode(ImagesModel.self, from: value)
//
//                                print(FULLResponse)
//
//                            }catch let error {
//                                print(error)
//                            }
//
//
//                        case .failure(let error):
//                            print(error)
//                        }
//                    })
//
//                case .failure(_): break
//                    // MBProgressHUD.hide(for: self.view, animated: true)
//                }
//            }
//        }
//    }
//}


struct ImagesModel : Codable {
    
    let data : Datum?
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
}

struct Datum : Codable {
    
    let imagePoints : [ImagePoint]?
    
    enum CodingKeys: String, CodingKey {
        case imagePoints = "imagePoints"
    }
    
    
}
struct ImagePoint : Codable {
    
    let h : Int?
    let w : Int?
    let x : Int?
    let y : Int?
    
    enum CodingKeys: String, CodingKey {
        case h = "h"
        case w = "w"
        case x = "x"
        case y = "y"
    }
    
}
