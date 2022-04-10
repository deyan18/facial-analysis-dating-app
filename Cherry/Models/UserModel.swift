//
//  UserModel.swift
//  Cherry
//
//  Created by Deyan on 10/4/22.
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
    var wantsSimilar: Bool = true
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
        self.wantsSimilar = data["buscaSimilar"] as? Bool ?? true
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
