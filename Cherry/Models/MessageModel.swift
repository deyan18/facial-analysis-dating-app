//
//  MessageModel.swift
//  Cherry
//
//  Created by Deyan on 10/4/22.
//

import SwiftUI
import Foundation
import Firebase
import CoreLocation

struct MessageModel: Identifiable{
    
    let id : UUID = UUID()
    let date: Date
    let text: String
    let senderUID: String
    let receiverUID: String
    
    init(_ texto: String, emisorId: String, receptorId: String, fecha: Date){
        self.text = texto
        self.date = fecha
        self.senderUID = emisorId
        self.receiverUID = receptorId
    }
    
    init(_ texto: String, emisorId: String, receptorId: String){
        self.init(texto, emisorId: emisorId, receptorId: receptorId, fecha: Date())
    }
    
    init(data: [String: Any]){
        self.text = data["texto"] as? String ?? ""
        self.date = (data["fecha"] as? Timestamp)?.dateValue() ?? Date()
        self.senderUID = data["emisorId"] as? String ?? ""
        self.receiverUID = data["receptorId"] as? String ?? ""
    }
}
