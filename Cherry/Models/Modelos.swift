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

struct UsuarioModel: Hashable, Identifiable {
    var id: String { uid }
    
    let uid, nombre, sobreMi, url1, url2, url3, urlV, genero: String
    let busco: [String]
    let fechaNacimiento: Date
    let edad: Int
    let atributos: [String]
    var ubicacion: CLLocation
    var distanciaMetros = 0.0
    var edadMin: Int
    var edadMax: Int
    var distanciaRasgos: Double = -1.0
    var urls: [String] = []
    var buscaSimilar: Bool = true
    init(data: [String: Any]){
        self.uid = data["uid"] as? String ?? ""
        self.nombre = data["nombre"] as? String ?? ""
        self.sobreMi = data["sobreMi"] as? String ?? ""
        self.genero = data["genero"] as? String ?? ""
        self.url1 = data["url1"] as? String ?? ""
        self.url2 = data["url2"] as? String ?? ""
        self.url3 = data["url3"] as? String ?? ""
        self.urlV = data["urlV"] as? String ?? ""
        self.busco = data["busco"] as? [String] ?? []
        self.fechaNacimiento =  (data["fechaNacimiento"] as? Timestamp)?.dateValue() ?? Date()
        self.edad = calcularEdad(fecha: fechaNacimiento)
        self.atributos = data["atributos"] as? [String] ?? []
        
        let geopoint = data["ubicacion"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
        let latitude: CLLocationDegrees = geopoint.latitude
        let longtitude: CLLocationDegrees = geopoint.longitude
        self.ubicacion = CLLocation(latitude: latitude, longitude: longtitude)
        
        self.edadMin = data["edadMin"] as? Int ?? 18
        self.edadMax = data["edadMax"] as? Int ?? 99
        self.urls = [url1, url2, url3]
        self.buscaSimilar = data["buscaSimilar"] as? Bool ?? true
    }
}

func calcularEdad(fecha: Date) -> Int{
    var age: Int
    let cumple = Calendar.current.dateComponents([.year, .month, .day], from: fecha)
    let now = Calendar.current.dateComponents([.year, .month, .day], from: Date.now)
    let ageComponents = Calendar.current.dateComponents([.year], from: cumple, to: now)
    
    age = ageComponents.year!
    return age
}

struct MensajeModel: Identifiable{
    
    let id : UUID = UUID()
    let fecha: Date
    let texto: String
    let emisorId: String
    let receptorId: String
    
    init(_ texto: String, emisorId: String, receptorId: String, fecha: Date){
        self.texto = texto
        self.fecha = fecha
        self.emisorId = emisorId
        self.receptorId = receptorId
    }
    
    init(_ texto: String, emisorId: String, receptorId: String){
        self.init(texto, emisorId: emisorId, receptorId: receptorId, fecha: Date())
    }
    
    init(data: [String: Any]){
        self.texto = data["texto"] as? String ?? ""
        self.fecha = (data["fecha"] as? Timestamp)?.dateValue() ?? Date()
        self.emisorId = data["emisorId"] as? String ?? ""
        self.receptorId = data["receptorId"] as? String ?? ""
    }
}

struct RecienteModel: Identifiable, Hashable{
    let id : UUID = UUID()
    let texto, emisorId, receptorId, urlFoto, nombre: String
    let fecha: Date
    var esLeido: Bool
    
    init(data: [String: Any]){
        self.texto = data["texto"] as? String ?? ""
        self.nombre = data["nombre"] as? String ?? ""
        self.emisorId = data["emisorId"] as? String ?? ""
        self.receptorId = data["receptorId"] as? String ?? ""
        self.urlFoto = data["urlFoto"] as? String ?? ""
        self.fecha = (data["fecha"] as? Timestamp)?.dateValue() ?? Date()
        self.esLeido = data["esLeido"] as? Bool ?? true
    }
}

struct AtributoModel: Identifiable, Hashable{
    let id : UUID = UUID()
    var texto: String
    var esSeleccionado: Bool = false
}


struct GeneroModel{
    var id = UUID()
    var name: String
    var isSelected: Bool = false
}
