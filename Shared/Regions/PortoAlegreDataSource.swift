//
//  PortoAlegreDataSource.swift
//  Fluss
//
//  Created by João Gabriel Pozzobon dos Santos on 06/05/24.
//

import SwiftUI

struct PortoAlegreDataSource: DataSource {
    var medicoes: [PortoAlegreReading] = []
    
    var readings: [PortoAlegreReading] {
        get {
            medicoes
        }
        set {
            medicoes = newValue
        }
    }
    
    var isSample: Bool? = false
    
    var name: String {
        return readings.isEmpty || isSample == true ? "" : "Porto Alegre"
    }
    
    static var sample: Self {
//        let niveis = [
//            PortoAlegreReading(nivel: 1.0, horaLeitura: "2023-10-07T10:00:00Z"),
//            PortoAlegreReading(nivel: 1.3, horaLeitura: "2023-10-07T11:00:00Z"),
//            PortoAlegreReading(nivel: 1.5, horaLeitura: "2023-10-07T12:00:00Z"),
//            PortoAlegreReading(nivel: 1.58, horaLeitura: "2023-10-07T13:00:00Z"),
//            PortoAlegreReading(nivel: 2.0, horaLeitura: "2023-10-07T14:00:00Z"),
//        ]
        return PortoAlegreDataSource(medicoes: [], isSample: true)
    }
    
    static var empty: Self {
        return PortoAlegreDataSource()
    }
    
    static func alert(from reading: PortoAlegreReading) -> ReadingAlert {
        switch reading.level {
        case 0..<0.6:
            return .normal
        case 0.6..<0.8:
            return .observacao
        case 0.8..<1.2:
            return .atencao
        case 1.2..<3:
            return .alerta
        default:
            return .alertaMaximo
        }
    }
}

struct PortoAlegreReading: Reading {
    var id: String {
        dados.horDataHora
    }
    
    var level: Double {
        horNivelAdotado/100.0
    }
    
    var date: Date {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions.insert(.withFractionalSeconds)
        let date = dateFormatter.date(from: dados.horDataHora)
        return date ?? .now
    }
    
    let horNivelAdotado: Double
    let dados: LeituraID
    
    private enum CodingKeys: String, CodingKey {
        case horNivelAdotado
        case dados = "id"
    }
    
    struct LeituraID: Codable, Hashable {
        let horDataHora: String
    }
}
