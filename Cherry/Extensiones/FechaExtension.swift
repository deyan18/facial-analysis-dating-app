//
//  FechaExtension.swift
//  Cherry
//
//  Created by Deyan on 13/2/22.
//

import SwiftUI

extension Date{
    
    func fechaString() -> String{
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        let diferenciaDias = self.diferenciaDias(fecha: Date())
        
        if diferenciaDias == 0{
            return "Hoy"
        }
        else if diferenciaDias == 1{
            return "Ayer"
        }
        else if diferenciaDias < 5 {
            let diaSemana = Calendar.current.component(.weekday, from: self) - 1
            return formatter.weekdaySymbols[diaSemana]
        }else if diferenciaDias > 365 {
            formatter.dateFormat = "d MMM y"
        }
        return formatter.string(from: self)
    }
    
    func diferenciaDias(fecha: Date) -> Int{
        let calendar = Calendar.current
        let fecha1 = calendar.startOfDay(for: self)
        let fecha2 = calendar.startOfDay(for: fecha)
        if let diferenciaDias = calendar.dateComponents([.day], from: fecha1, to: fecha2).day {
            return diferenciaDias
        }
        
        return 0
    }
}
