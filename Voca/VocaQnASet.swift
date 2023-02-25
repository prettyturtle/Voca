//
//  VocaQnASet.swift
//  Voca
//
//  Created by yc on 2023/02/25.
//

import Foundation

struct VocaQnASet {
    let id: Int
    let question: String
    let choices: [String]
    let answer: String
    var isSolved: SolveType = .none
    
    enum SolveType {
        case right
        case wrong
        case none
    }
    
    static var MOCK_DATA: [VocaQnASet] = [
        VocaQnASet(id: 0, question: "I", choices: ["제빵사", "나"], answer: "나"),
        VocaQnASet(id: 1, question: "teacher", choices: ["선생님", "기자"], answer: "선생님"),
        VocaQnASet(id: 2, question: "man", choices: ["은행원", "남자"], answer: "남자"),
        VocaQnASet(id: 3, question: "banker", choices: ["치과 의사", "은행원"], answer: "은행원"),
        VocaQnASet(id: 4, question: "reporter", choices: ["기자", "남자"], answer: "기자"),
        VocaQnASet(id: 5, question: "baker", choices: ["선생님", "제빵사"], answer: "제빵사"),
        VocaQnASet(id: 6, question: "dentist", choices: ["치과 의사", "나"], answer: "치과 의사"),
    ]
}
