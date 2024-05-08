//
//  ReadingDataAttributes.swift
//  Fluss
//
//  Created by João Gabriel Pozzobon dos Santos on 08/10/23.
//

#if os(iOS)
import ActivityKit

@available(iOS 16.1, *)
struct ReadingDataAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        let data: ParsedReadingData
    }
}
#endif
