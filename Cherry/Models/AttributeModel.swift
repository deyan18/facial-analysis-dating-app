//
//  AttributeModel.swift
//  Cherry
//
//  Created by Deyan on 10/4/22.
//

import SwiftUI
import Foundation
import Firebase
import CoreLocation

struct AttributeModel: Identifiable, Hashable{
    let id : UUID = UUID()
    var text: String
    var isSelected: Bool = false
}
