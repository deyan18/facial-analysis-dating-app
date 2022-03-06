//
//  Modelos.swift
//  Cherry
//
//  Created by Deyan on 25/1/22.
//

import SwiftUI
import Foundation
import Firebase
import CoreLocation

struct UserModel: Hashable, Identifiable {
    var id: String { uid }
    let uid, name, aboutMe, url1, url2, url3, urlV, gender: String
    let lookingFor: [String]
    let birthDate: Date
    let age: Int
    let attributes: [String]
    var location: CLLocation
    var distanceMetres = 0.0
    var ageMin: Int
    var ageMax: Int
    var distanceFeatures: Double = -1.0
    var urls: [String] = []
    var lookingForSimilar: Bool = true
    init(data: [String: Any]){
        self.uid = data["uid"] as? String ?? ""
        self.name = data["nombre"] as? String ?? ""
        self.aboutMe = data["sobreMi"] as? String ?? ""
        self.gender = data["genero"] as? String ?? ""
        self.url1 = data["url1"] as? String ?? ""
        self.url2 = data["url2"] as? String ?? ""
        self.url3 = data["url3"] as? String ?? ""
        self.urlV = data["urlV"] as? String ?? ""
        self.lookingFor = data["busco"] as? [String] ?? []
        self.birthDate =  (data["fechaNacimiento"] as? Timestamp)?.dateValue() ?? Date()
        self.age = calculateAge(birthDate: birthDate)
        self.attributes = data["atributos"] as? [String] ?? []
        
        let geopoint = data["ubicacion"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
        let latitude: CLLocationDegrees = geopoint.latitude
        let longtitude: CLLocationDegrees = geopoint.longitude
        self.location = CLLocation(latitude: latitude, longitude: longtitude)
        
        self.ageMin = data["edadMin"] as? Int ?? 18
        self.ageMax = data["edadMax"] as? Int ?? 99
        self.urls = [url1, url2, url3]
        self.lookingForSimilar = data["buscaSimilar"] as? Bool ?? true
    }
    
    
}
func calculateAge(birthDate: Date) -> Int{
    var age: Int
    let birth = Calendar.current.dateComponents([.year, .month, .day], from: birthDate)
    let now = Calendar.current.dateComponents([.year, .month, .day], from: Date.now)
    let ageComponents = Calendar.current.dateComponents([.year], from: birth, to: now)
    
    age = ageComponents.year!
    return age
}

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

struct AttributeModel: Identifiable, Hashable{
    let id : UUID = UUID()
    var text: String
    var isSelected: Bool = false
}


struct GenderModel{
    var id = UUID()
    var gender: String
    var isSelected: Bool = false
}
