//
//  Icons.swift
//  Voca
//
//  Created by yc on 2023/03/07.
//

import UIKit

enum Icon: String {
    case ellipsis = "ellipsis"
    case playFill = "play.fill"
    case backwardEndFill = "backward.end.fill"
    case forwardEndFill = "forward.end.fill"
    case pauseFill = "pause.fill"
    case speakerWave2 = "speaker.wave.2"
    case speakerWave2Fill = "speaker.wave.2.fill"
    case circle = "circle"
    case xmark = "xmark"
    case triangle = "triangle"
    case checkmarkCircleFill = "checkmark.circle.fill"
    case xmarkCircleFill = "xmark.circle.fill"
    
    var image: UIImage? { UIImage(systemName: self.rawValue) }
}
