//
//  Item.swift
//  FitLog
//
//  Created by Lucas Chaves Pinheiro on 13/05/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
