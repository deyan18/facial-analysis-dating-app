//
//  RecentMessageModel.swift
//  Cherry
//
//  Created by Deyan on 10/4/22.
//

import SwiftUI
import Foundation
import Firebase
import CoreLocation

struct RecentMessageModel: Identifiable, Hashable{
    let id : UUID = UUID()
    let text, senderUID, receiverUID, url, name: String
    let date: Date
    var isRead: Bool
    
    init(data: [String: Any]){
        self.text = data["texto"] as? String ?? ""
        self.name = data["nombre"] as? String ?? ""
        self.senderUID = data["emisorId"] as? String ?? ""
        self.receiverUID = data["receptorId"] as? String ?? ""
        self.url = data["urlFoto"] as? String ?? ""
        self.date = (data["fecha"] as? Timestamp)?.dateValue() ?? Date()
        self.isRead = data["esLeido"] as? Bool ?? true
    }
}
