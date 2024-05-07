//
//  DataSource.swift
//  Fluss
//
//  Created by João Gabriel Pozzobon dos Santos on 06/05/24.
//

import SwiftUI

protocol DataSource: Codable, Equatable, Hashable {
    associatedtype R: Reading
    
    var readings: [R] { get set }
    
    var name: String { get }
    var isSample: Bool? { get set }
    
    static var sample: Self { get }
    static var empty: Self { get }
    static func alert(from reading: R) -> ReadingAlert
    
    var sortedReadings: [R] { get }
    var delta: Double { get }
    var currentReading: R? { get }
    var alert: ReadingAlert { get }
}

extension DataSource {
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
        if isSample == true {
            return .sample
        }
        
        if let last = sortedReadings.last {
            return Self.alert(from: last)
        }
        
        return .failure
    }
}
