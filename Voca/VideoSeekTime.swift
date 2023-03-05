//
//  VideoSeekTime.swift
//  Voca
//
//  Created by yc on 2023/03/05.
//

import Foundation

enum VideoSeekTime: CaseIterable {
    case t_5
    case t_10
    
    var value: Double {
        switch self {
        case .t_5: return 5.0
        case .t_10: return 10.0
        }
    }
    
    var text: String {
        return "\(Int(self.value))"
    }
}
