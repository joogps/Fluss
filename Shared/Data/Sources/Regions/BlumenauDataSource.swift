//
//  BlumenauDataSource.swift
//  Fluss
//
//  Created by João Gabriel Pozzobon dos Santos on 08/10/23.
//

import SwiftUI

struct BlumenauDataSource: ReadingDataSource {
    var niveis: [BlumenauReading] = []
    
    var readings: [BlumenauReading] {
        niveis
    }
    
    static var name: String {
        return "Blumenau"
    }
    
    static var url: URL {
        URL(string: "https://alertablu.blumenau.sc.gov.br/static/data/nivel_oficial.json?a="+String(Int(ceil(Double.random(in: 0...9999999)))))!
    }
    
    static func fetch() async  -> BlumenauDataSource {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            var dataSource = try JSONDecoder().decode(BlumenauDataSource.self, from: data)
            dataSource.niveis = Array(dataSource.readings.suffix(24))
            
            return dataSource
        } catch {
            return BlumenauDataSource()
        }
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
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: horaLeitura)
        return date ?? .now
    }
    
    let nivel: Double
    let horaLeitura: String
}
