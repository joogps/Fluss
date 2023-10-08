//
//  Task+AnyCancellable.swift
//  Fluss
//
//  Created by João Gabriel Pozzobon dos Santos on 08/10/23.
//

import Combine

extension Task {
    func eraseToAnyCancellable() -> AnyCancellable {
        AnyCancellable(cancel)
    }
    
    func store(in set: inout Set<AnyCancellable>) {
        set.insert(eraseToAnyCancellable())
    }
}
