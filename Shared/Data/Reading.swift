//
//  Reading.swift
//  Fluss
//
//  Created by João Gabriel Pozzobon dos Santos on 06/05/24.
//

import Foundation

protocol Reading: Codable, Identifiable, Equatable, Hashable {
    var id: ID { get }
    
    var level: Double { get }
    var date: Date { get }
}
