//
//  SelectVocaView.swift
//  Voca
//
//  Created by yc on 2023/02/25.
//

import UIKit
import AVFoundation

import Then
import SnapKit

protocol SelectVocaViewDelegate: AnyObject {
    func selectVocaView(selectVoca: SelectVocaView, moveToNextStep currentQnAIndex: Int)
    func selectVocaView(selectVoca: SelectVocaView, didEnd results: [VocaQnASet])
}

final class SelectVocaView: UIView, StudyModeView {
    
    var vocaQnASets: [VocaQnASet]
    var currentQnAIndex = 0
    
    var fxPlayer: AVAudioPlayer?
    var standardPlayer: AVAudioPlayer?
    
    weak var delegate: SelectVocaViewDelegate?
    
    init(vocaQnASets: [VocaQnASet]) {
        self.vocaQnASets = vocaQnASets
        super.init(frame: .zero)
        setupView()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            return
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var descriptionLabel = UILabel().then {
        $0.text = "문제를 보고,\n그에 알맞은 답을 찾아보세요."
        $0.font = .systemFont(ofSize: 24.0, weight: .bold)
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    private lazy var questionBackgroundView = UIView().then {
        $0.backgroundColor = .secondarySystemBackground
    }
    private lazy var questionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 30.0, weight: .bold)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    private lazy var choiceButtonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.spacing = 16.0
    }
    
    func setupVocaQnASet() {
        questionLabel.text = vocaQnASets[currentQnAIndex].question
        setupChoiceButton()
    }
    
    func setupChoiceButton() {
        let choices = vocaQnASets[currentQnAIndex].choices
        for index in 0..<choices.count {
            let choiceButton = ChoiceButton()
            choiceButton.setupLabel(index: index, text: choices[index])
            choiceButton.addTarget(self, action: #selector(didTapChoiceButton), for: .touchUpInside)
            choiceButton.snp.makeConstraints {
                $0.height.equalTo(75.0)
            }
            choiceButtonStackView.addArrangedSubview(choiceButton)
        }
    }
    
    func checkAnswer(choice: String) -> Bool {
        return choice == vocaQnASets[currentQnAIndex].answer
    }
    
    func resetChoiceButtonStackView() {
        choiceButtonStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    @objc func didTapChoiceButton(_ button: ChoiceButton) {
        guard let text = button.text else {
            return
        }
        
        let isRight = checkAnswer(choice: text)
        
        let fxName = isRight ? "sfx_correct" : "sfx_wrong"
        
        guard let fxURL = Bundle.main.url(forResource: fxName, withExtension: "mp3") else {
            return
        }
        
        do {
            fxPlayer = try AVAudioPlayer(contentsOf: fxURL)
        } catch {
            return
        }
        fxPlayer?.delegate = self
        fxPlayer?.prepareToPlay()
        fxPlayer?.play()
        
        choiceButtonStackView.arrangedSubviews.forEach {
            guard let button = $0 as? ChoiceButton else { return }
            button.isEnabled = false
        }
        
        button.setupCheckedView(isRight: isRight)
        vocaQnASets[currentQnAIndex].isSolved = isRight ? .right : .wrong
    }
    
    func playStandard() {
        let standardURLString = "https://t1.daumcdn.net/cfile/tistory/995FA1335CDE8FD41D"
        guard let standardURL = URL(string: standardURLString) else {
            moveToNextStep()
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: standardURL)
                standardPlayer = try AVAudioPlayer(data: data)
                standardPlayer?.delegate = self
                standardPlayer?.prepareToPlay()
                standardPlayer?.play()
            } catch {
                moveToNextStep()
                return
            }
        }
    }
    
    func moveToNextStep() {
        if self.currentQnAIndex < self.vocaQnASets.count - 1 {
            self.currentQnAIndex += 1
            self.delegate?.selectVocaView(selectVoca: self, moveToNextStep: self.currentQnAIndex)
            self.resetChoiceButtonStackView()
            self.setupVocaQnASet()
        } else {
            self.delegate?.selectVocaView(selectVoca: self, didEnd: self.vocaQnASets)
        }
    }
    
    private func setupView() {
        backgroundColor = .systemBackground
        [
            descriptionLabel,
            questionBackgroundView,
            questionLabel,
            choiceButtonStackView
        ].forEach {
            addSubview($0)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.top.equalToSuperview().inset(32.0)
        }
        questionBackgroundView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(32.0)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(160.0)
        }
        questionLabel.snp.makeConstraints {
            $0.centerY.equalTo(questionBackgroundView.snp.centerY)
            $0.leading.trailing.equalTo(questionBackgroundView).inset(16.0)
        }
        choiceButtonStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.top.equalTo(questionBackgroundView.snp.bottom).offset(32.0)
        }
    }
}

extension SelectVocaView: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        if player == fxPlayer { // 효과음 재생이 끝났을 때
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.playStandard()
            }
        } else if player == standardPlayer { // 원어민 재생이 끝났을 때
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.moveToNextStep()
            }
        }
    }
}
