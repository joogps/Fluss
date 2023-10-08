//
//  Leitura.swift
//  Fluss
//
//  Created by João Gabriel Pozzobon dos Santos on 08/10/23.
//

import SwiftUI

struct Leitura: Codable, Equatable, Hashable {
    var niveis: [LeituraNivel] = []
    var isSample: Bool? = false
    
    var cidade: String {
        return niveis.isEmpty || isSample == true ? "" : "Blumenau"
    }
    
    var alerta: NivelAlerta {
        if isSample == true {
            return .sample
        }
        if niveis.isEmpty {
            return .failure
        }
        return NivelAlerta.from(nivel: sortedNiveis.last?.nivel ?? 0)
    }
    
    var nivelAtual: LeituraNivel? {
        sortedNiveis.last
    }
    
    var variacao: Double {
        let niveis = sortedNiveis
        
        guard let ultimo = niveis.last, let penultimo = niveis.dropLast().last else {
            return 0
        }
        
        return ultimo.nivel - penultimo.nivel
    }
    
    var sortedNiveis: [LeituraNivel] {
        niveis.sorted { $0.dataLeitura < $1.dataLeitura }
    }
    
    static var sample: Leitura {
        let niveis = [
            LeituraNivel(nivel: 1.0, horaLeitura: "2023-10-07T10:00:00Z"),
            LeituraNivel(nivel: 1.3, horaLeitura: "2023-10-07T11:00:00Z"),
            LeituraNivel(nivel: 1.5, horaLeitura: "2023-10-07T12:00:00Z"),
            LeituraNivel(nivel: 1.58, horaLeitura: "2023-10-07T13:00:00Z"),
            LeituraNivel(nivel: 2.0, horaLeitura: "2023-10-07T14:00:00Z"),
        ]
        return Leitura(niveis: niveis, isSample: true)
    }
    
    static var empty: Leitura {
        return Leitura()
    }
}

enum NivelAlerta {
    case normal
    case observacao
    case atencao
    case alerta
    case alertaMaximo
    
    case sample
    case failure
    
    func color() -> Color {
        switch self {
        case .normal:
            return .green
        case .observacao:
            return .yellow
        case .atencao:
            return .orange
        case .alerta:
            return .red
        case .alertaMaximo:
            return .purple
        case .sample, .failure:
            return .accent
        }
    }
    
    func text() -> String {
        switch self {
        case .normal:
            return "Normal"
        case .observacao:
            return "Observação"
        case .atencao:
            return "Atenção"
        case .alerta:
            return "Alerta"
        case .alertaMaximo:
            return "Alerta Máximo"
        case .sample:
            return "Exemplo"
        case .failure:
            return "Falha ao obter dados"
        }
    }
    
    func symbol() -> String {
        switch self {
        case .normal:
            return "checkmark.circle.fill"
        case .observacao:
            return "eye.fill"
        case .atencao:
            return "exclamationmark.circle.fill"
        case .alerta:
            return "exclamationmark.triangle.fill"
        case .alertaMaximo:
            return "exclamationmark.octagon.fill"
        case .sample:
            return "circle.fill"
        case .failure:
            return "bolt.slash.fill"
        }
    }
    
    static func from(nivel: Double) -> NivelAlerta {
        switch nivel {
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

struct LeituraNivel: Codable, Identifiable, Equatable, Hashable {
    let id = UUID()
    
    let nivel: Double
    let horaLeitura: String
    
    var dataLeitura: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return dateFormatter.date(from: horaLeitura) ?? .now
    }
}
