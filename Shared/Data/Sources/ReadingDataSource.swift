//
//  DataSource.swift
//  Fluss
//
//  Created by João Gabriel Pozzobon dos Santos on 06/05/24.
//

import SwiftUI

protocol ReadingDataSource: Codable, Equatable, Hashable {
    associatedtype R: Reading
    
    var readings: [R] { get }
    
    static var name: String { get }
    static var url: URL { get }
    
    static func alert(from reading: R) -> ReadingAlert
    
    static func fetch() async -> Self
}

extension ReadingDataSource {
    func parsed() -> ParsedReadingData {
        let readings = self.sortedReadings.map { $0.parsed() }
        return ParsedReadingData(readings: readings, name: Self.name, alert: alert)
    }
    
    var sortedReadings: [R] {
        readings.sorted { $0.date < $1.date }
    }
    
    var delta: Double {
        let niveis = sortedReadings
        
        guard let last = niveis.last, let secondLast = niveis.dropLast().last else {
            return 0
        }
        
        return last.level - secondLast.level
    }
    
    var currentReading: R? {
        sortedReadings.last
    }
    
    var alert: ReadingAlert {
        if let last = sortedReadings.last {
            return Self.alert(from: last)
        }
        
        return .failure
    }
}
