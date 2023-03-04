//
//  VideoRate.swift
//  Voca
//
//  Created by yc on 2023/03/04.
//

import Foundation

enum VideoRate: CaseIterable {
    case rate_0_5
    case rate_0_75
    case `default`
    case rate_1_5
    case rate_1_75
    case rate_2_0
    
    var value: Float {
        switch self {
        case .rate_0_5: return 0.5
        case .rate_0_75: return 0.75
        case .`default`: return 1.0
        case .rate_1_5: return 1.5
        case .rate_1_75: return 1.75
        case .rate_2_0: return 2.0
        }
    }
    
    var text: String {
        return "\(self.value)"
    }
}
