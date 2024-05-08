//
//  API.swift
//  Fluss
//
//  Created by João Gabriel Pozzobon dos Santos on 07/10/23.
//

import Foundation

struct API {
    static func fetch(region: Region) async -> ParsedReadingData {
        let data: any ReadingDataSource
        
        switch region {
        case .blumenau, .unknown:
            data = await BlumenauDataSource.fetch()
        case .portoAlegre:
            data = await PortoAlegreDataSource.fetch()
        }
        
        return data.parsed()
    }
}
