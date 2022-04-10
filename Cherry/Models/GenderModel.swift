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

struct GenderModel{
    var id = UUID()
    var gender: String
    var isSelected: Bool = false
}
