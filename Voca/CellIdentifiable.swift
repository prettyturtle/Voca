//
//  CellIdentifiable.swift
//  Voca
//
//  Created by yc on 2023/02/26.
//

import Foundation

protocol CellIdentifiable {
    static var identifier: String { get }
}

extension CellIdentifiable {
    static var identifier: String { return String(describing: self) }
}

