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
    
    static func fetchLeituras() async -> Leitura {
        do {
            let (data, _) = try await URLSession.shared.data(from: urlBlumenau)
            var leitura = try JSONDecoder().decode(Leitura.self, from: data)
            leitura.niveis = Array(leitura.niveis.suffix(24))
            
            return leitura
        } catch {
            return Leitura.empty
        }
    }
}
