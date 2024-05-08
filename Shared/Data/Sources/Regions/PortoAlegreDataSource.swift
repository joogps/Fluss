//
//  PortoAlegreDataSource.swift
//  Fluss
//
//  Created by João Gabriel Pozzobon dos Santos on 06/05/24.
//

import SwiftUI

struct PortoAlegreDataSource: ReadingDataSource {
    var medicoes: [PortoAlegreReading] = []
    
    var readings: [PortoAlegreReading] {
        medicoes
    }
    
    static var name: String {
        return "Porto Alegre"
    }
    
    static var url: URL {
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-24*60*60)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        let baseURL = "https://www.snirh.gov.br/hidroweb/rest/api/documento/gerarTelemetricas?codigosEstacoes=300151130&tipoArquivo=2&periodoInicial=\(dateFormatter.string(from: startDate))&periodoFinal=\(dateFormatter.string(from: endDate))"
        
        return URL(string: baseURL)!
    }
    
    static func fetch() async  -> PortoAlegreDataSource {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            var dataSource = try JSONDecoder().decode([PortoAlegreDataSource].self, from: data)[0]
            dataSource.medicoes = Array(dataSource.readings.suffix(24))
            
            return dataSource
        } catch {
            return PortoAlegreDataSource()
        }
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
        metadata.horDataHora
    }
    
    var level: Double {
        horNivelAdotado/100.0
    }
    
    var date: Date {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions.insert(.withFractionalSeconds)
        let date = dateFormatter.date(from: metadata.horDataHora)
        return date ?? .now
    }
    
    let horNivelAdotado: Double
    let metadata: Metadata
    
    private enum CodingKeys: String, CodingKey {
        case horNivelAdotado
        case metadata = "id"
    }
    
    struct Metadata: Codable, Hashable {
        let horDataHora: String
    }
}
