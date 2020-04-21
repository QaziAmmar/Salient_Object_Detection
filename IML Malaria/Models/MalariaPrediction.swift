//
//  MalariaPrediction.swift
//  IML Malaria
//
//  Created by Qazi Ammar Arshad on 09/04/2020.
//  Copyright © 2020 Neberox Technologies. All rights reserved.
//

import Foundation

struct MalariaPrediction : Codable {
    
    let data : ModelScore?
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
}


struct ModelScore : Codable {
    
    let prediction : String?
    let confidence : Double?

    enum CodingKeys: String, CodingKey {

        case prediction = "prediction"
        case confidence = "confidence"
    }
}




