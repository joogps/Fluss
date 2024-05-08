//
//  ParsedReadingData.swift
//  Fluss
//
//  Created by João Gabriel Pozzobon dos Santos on 07/05/24.
//

import SwiftUI

struct ParsedReadingData: Codable, Equatable, Hashable {
    var readings: [ParsedReading]
    var name: String
    var alert: ReadingAlert
    
    static var sample: Self {
        let now = Date()
        let readings = [
            ParsedReading(level: 1.0, date: now.addingTimeInterval(-60*120)),
            ParsedReading(level: 1.3, date: now.addingTimeInterval(-60*90)),
            ParsedReading(level: 1.5, date: now.addingTimeInterval(-60*60)),
            ParsedReading(level: 1.58, date: now.addingTimeInterval(-60*30)),
            ParsedReading(level: 2.0, date: now),
        ]
        
        return ParsedReadingData(readings: readings, name: "", alert: .sample)
    }
    
    static var empty: Self {
        ParsedReadingData(readings: [], name: "", alert: .sample)
    }
    
    var sortedReadings: [ParsedReading] {
        readings.sorted { $0.date < $1.date }
    }
    
    var delta: Double {
        let niveis = sortedReadings
        
        guard let last = niveis.last, let secondLast = niveis.dropLast().last else {
            return 0
        }
        
        return last.level - secondLast.level
    }
    
    var currentReading: ParsedReading? {
        sortedReadings.last
    }
}

struct ParsedReading: Codable, Identifiable, Equatable, Hashable {
    var id: Date { date }
    
    var level: Double
    var date: Date
}
