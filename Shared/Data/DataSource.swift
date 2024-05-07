//
//  DataSource.swift
//  Fluss
//
//  Created by João Gabriel Pozzobon dos Santos on 06/05/24.
//

import SwiftUI

protocol DataSource: Codable, Equatable, Hashable {
    associatedtype LR: Reading
    
    var readings: [LR] { get set }
    
    var name: String { get }
    var isSample: Bool? { get set }
    
    static var sample: Self { get }
    static var empty: Self { get }
    static func alert(from reading: LR) -> ReadingAlert
    
    var sortedReadings: [LR] { get }
    var delta: Double { get }
    var currentReading: LR? { get }
    var alert: ReadingAlert { get }
}

extension DataSource {
    var sortedReadings: [LR] {
        readings.sorted { $0.date < $1.date }
    }
    
    var delta: Double {
        let niveis = sortedReadings
        
        guard let last = niveis.last, let secondLast = niveis.dropLast().last else {
            return 0
        }
        
        return last.level - secondLast.level
    }
    
    var currentReading: LR? {
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
