//
//  API.swift
//  Fluss
//
//  Created by João Gabriel Pozzobon dos Santos on 07/10/23.
//

import Foundation

struct API {
    static var urlBlumenau: URL {
        URL(string: "https://alertablu.blumenau.sc.gov.br/static/data/nivel_oficial.json?a="+String(Int(ceil(Double.random(in: 0...9999999)))))!
    }
    
    static var urlPortoAlegre: URL {
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-24 * 60 * 60)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        let baseURL = "https://www.snirh.gov.br/hidroweb/rest/api/documento/gerarTelemetricas?codigosEstacoes=300151130&tipoArquivo=2&periodoInicial=\(dateFormatter.string(from: startDate))&periodoFinal=\(dateFormatter.string(from: endDate))"
        
        print(baseURL)
        return URL(string: baseURL)!
    }
    
    static func fetch(region: Region) async -> any DataSource {
        switch region {
        case .blumenau, .unknown:
            return await fetchBlumenau()
        case .portoAlegre:
            return await fetchPortoAlegre()
        }
    }
    
    static func fetchPortoAlegre() async -> PortoAlegreDataSource {
        do {
            let (data, _) = try await URLSession.shared.data(from: urlPortoAlegre)
            var leitura = try JSONDecoder().decode([PortoAlegreDataSource].self, from: data)[0]
            leitura.readings = Array(leitura.readings.suffix(24))
            
            return leitura
        } catch {
            return PortoAlegreDataSource.empty
        }
    }
    
    static func fetchBlumenau() async -> BlumenauDataSource {
        do {
            let (data, _) = try await URLSession.shared.data(from: urlBlumenau)
            var leitura = try JSONDecoder().decode(BlumenauDataSource.self, from: data)
            leitura.readings = Array(leitura.readings.suffix(24))
            
            return leitura
        } catch {
            return BlumenauDataSource.empty
        }
    }
}
