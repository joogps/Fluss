//
//  ReadingAlert.swift
//  Fluss
//
//  Created by João Gabriel Pozzobon dos Santos on 06/05/24.
//

import SwiftUI

enum ReadingAlert: Codable {
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
}
