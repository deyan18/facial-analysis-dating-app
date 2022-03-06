//
//  FechaExtension.swift
//  Cherry
//
//  Created by Deyan on 13/2/22.
//

import SwiftUI

extension Date{
    
    func dateString() -> String{
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        let daysInBetween = self.daysBetween(date: Date())
        
        if daysInBetween == 0{
            return "Hoy"
        }
        else if daysInBetween == 1{
            return "Ayer"
        }
        else if daysInBetween < 5 {
            let weekDay = Calendar.current.component(.weekday, from: self) - 1
            return formatter.weekdaySymbols[weekDay]
        }else if daysInBetween > 365 {
            formatter.dateFormat = "d MMM y"
        }
        return formatter.string(from: self)
    }
    
    func daysBetween(date: Date) -> Int{
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: self)
        let date2 = calendar.startOfDay(for: date)
        if let daysInBetween = calendar.dateComponents([.day], from: date1, to: date2).day {
            return daysInBetween
        }
        
        return 0
    }
}
