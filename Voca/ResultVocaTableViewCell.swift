//
//  ResultVocaTableViewCell.swift
//  Voca
//
//  Created by yc on 2023/02/26.
//

import UIKit

import Then
import SnapKit

protocol ResultVocaTableViewCellDelegate: AnyObject {
    func resultVocaTableViewCell(cell: ResultVocaTableViewCell, playStandard button: UIButton)
}

final class ResultVocaTableViewCell: UITableViewCell, CellIdentifiable {
    
    weak var delegate: ResultVocaTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 22.0, weight: .bold)
    }
    private lazy var descriptionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18.0, weight: .bold)
        $0.textColor = .systemGray
    }
    private lazy var standardPlayButton = UIButton().then {
        $0.tintColor = .secondaryLabel
        $0.setImage(UIImage(systemName: "speaker.wave.2"), for: .normal)
        $0.addTarget(self, action: #selector(didTapStandardPlayButton), for: .touchUpInside)
    }
    private lazy var correctMarkImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    
    static func setupIsPlayingStandard(isPlaying: Bool, button: UIButton) {
        let imageName = isPlaying ? "speaker.wave.2.fill" : "speaker.wave.2"
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.tintColor = isPlaying ? .systemOrange : .secondaryLabel
    }
    
    func setupData(resultItem: VocaQnASet) {
        titleLabel.text = resultItem.question
        descriptionLabel.text = resultItem.answer
        
        switch resultItem.isSolved {
        case .right:
            correctMarkImageView.image = UIImage(systemName: "circle")
            correctMarkImageView.tintColor = .systemGreen
        case .wrong:
            correctMarkImageView.image = UIImage(systemName: "xmark")
            correctMarkImageView.tintColor = .systemRed
        case .none:
            correctMarkImageView.image = UIImage(systemName: "triangle")
            correctMarkImageView.tintColor = .systemYellow
        }
    }
    
    func setupView() {
        separatorInset = .zero
        [
            titleLabel,
            descriptionLabel,
            standardPlayButton,
            correctMarkImageView
        ].forEach {
            contentView.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(16.0)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8.0)
            $0.leading.bottom.equalToSuperview().inset(16.0)
        }
        standardPlayButton.snp.makeConstraints {
            $0.size.equalTo(36.0)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(8.0)
            $0.centerY.equalTo(titleLabel.snp.centerY)
        }
        correctMarkImageView.snp.makeConstraints {
            $0.size.equalTo(32.0)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16.0)
        }
    }
}

extension ResultVocaTableViewCell {
    @objc func didTapStandardPlayButton(_ sender: UIButton) {
        delegate?.resultVocaTableViewCell(cell: self, playStandard: sender)
    }
}
