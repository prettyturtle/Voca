//
//  EpisodeType.swift
//  Voca
//
//  Created by yc on 2023/02/25.
//

import Foundation

enum EpisodeType {
    case voca
    
    var text: (en: String, ko: String) {
        switch self {
        case .voca:
            return ("Voca", "단어 학습")
        }
    }
    
    var description: String {
        switch self {
        case .voca:
            return "원어민 영상을 통해 단어의 뜻과 발음을 확인한 후\n퀴즈를 풀며 정확하게 기억하고 있는지 확인해 보세요."
        }
    }
}
