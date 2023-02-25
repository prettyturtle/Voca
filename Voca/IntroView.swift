//
//  IntroView.swift
//  Voca
//
//  Created by yc on 2023/02/25.
//

import UIKit

import Then
import SnapKit

protocol IntroViewDelegate: AnyObject {
    func introView(_ intro: IntroView, start didTapButton: UIButton)
}

final class IntroView: UIView, StudyModeView {
    
    let episodeType: EpisodeType
    weak var delegate: IntroViewDelegate?
    
    init(episodeType: EpisodeType) {
        self.episodeType = episodeType
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    private lazy var typeEnLabel = UILabel().then {
        $0.text = episodeType.text.en
        $0.font = .systemFont(ofSize: 20.0, weight: .semibold)
        $0.textColor = .systemGray2
    }
    private lazy var typeKoLabel = UILabel().then {
        $0.text = episodeType.text.ko
        $0.font = .systemFont(ofSize: 36.0, weight: .black)
        $0.textColor = .label
    }
    private lazy var underlineView = UIView().then {
        $0.backgroundColor = .systemGray
    }
    private lazy var descriptionLabel = UILabel().then {
        $0.text = episodeType.description
        $0.font = .systemFont(ofSize: 16.0, weight: .medium)
        $0.textColor = .systemGray2
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    private lazy var startButton = AlphaButton().then {
        $0.style = .fill(backgroundColor: .systemPink)
        $0.setTitle("시작하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 20.0, weight: .bold)
        $0.addTarget(self, action: #selector(didTapStartButton), for: .touchUpInside)
    }
    
    func setupView() {
        backgroundColor = .systemBackground
        
        [
            typeEnLabel,
            typeKoLabel,
            underlineView,
            descriptionLabel,
            startButton
        ].forEach {
            addSubview($0)
        }
        
        typeKoLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(120.0)
        }
        underlineView.snp.makeConstraints {
            $0.leading.trailing.equalTo(typeKoLabel)
            $0.top.equalTo(typeKoLabel.snp.bottom).offset(2.0)
            $0.height.equalTo(1.0)
        }
        typeEnLabel.snp.makeConstraints {
            $0.leading.equalTo(typeKoLabel.snp.leading)
            $0.bottom.equalTo(typeKoLabel.snp.top).offset(-4.0)
        }
        descriptionLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.top.equalTo(typeKoLabel.snp.bottom).offset(60.0)
        }
        startButton.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview().inset(16.0)
            $0.height.equalTo(48.0)
        }
    }
    
    @objc func didTapStartButton(_ button: UIButton) {
        delegate?.introView(self, start: button)
    }
}
