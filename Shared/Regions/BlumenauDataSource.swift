//
//  BlumenauDataSource.swift
//  Fluss
//
//  Created by João Gabriel Pozzobon dos Santos on 08/10/23.
//

import SwiftUI

struct BlumenauDataSource: DataSource {
    var niveis: [BlumenauReading] = []
    
    var readings: [BlumenauReading] {
        get {
            niveis
        }
        set {
            niveis = newValue
        }
    }
    
    var isSample: Bool? = false
    
    var name: String {
        return readings.isEmpty || isSample == true ? "" : "Blumenau"
    }
    
    static var sample: BlumenauDataSource {
        let niveis = [
            BlumenauReading(nivel: 1.0, horaLeitura: "2023-10-07T10:00:00Z"),
            BlumenauReading(nivel: 1.3, horaLeitura: "2023-10-07T11:00:00Z"),
            BlumenauReading(nivel: 1.5, horaLeitura: "2023-10-07T12:00:00Z"),
            BlumenauReading(nivel: 1.58, horaLeitura: "2023-10-07T13:00:00Z"),
            BlumenauReading(nivel: 2.0, horaLeitura: "2023-10-07T14:00:00Z"),
        ]
        return BlumenauDataSource(niveis: niveis, isSample: true)
    }
    
    static var empty: BlumenauDataSource {
        return BlumenauDataSource()
    }
    
    static func alert(from reading: BlumenauReading) -> ReadingAlert {
        switch reading.level {
        case 0..<3:
            return .normal
        case 3..<4:
            return .observacao
        case 4..<6:
            return .atencao
        case 6..<8:
            return .alerta
        default:
            return .alertaMaximo
        }
    }
}

struct BlumenauReading: Reading {
    var id: String {
        horaLeitura
    }
    
    var level: Double {
        nivel
    }
    
    var date: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        var date = dateFormatter.date(from: horaLeitura)
        date?.addTimeInterval(-60*60*3)
        return date ?? .now
    }
    
    let nivel: Double
    let horaLeitura: String
}
