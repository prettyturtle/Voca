//
//  ChoiceButton.swift
//  Voca
//
//  Created by yc on 2023/02/26.
//

import UIKit

import Then
import SnapKit

final class ChoiceButton: UIButton {
    
    var index: Int?
    var text: String?
    
    private lazy var indexLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20.0, weight: .bold)
        $0.textAlignment = .center
    }
    private lazy var textLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20.0, weight: .semibold)
        $0.textAlignment = .center
    }
    private lazy var resultIconImageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFit
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLabel(index: Int, text: String) {
        self.index = index
        self.text = text
        
        if let indexEn = UnicodeScalar(65 + index) {
            indexLabel.text = "\(indexEn)."
        } else {
            indexLabel.text = "."
        }
        
        textLabel.text = text
    }
    
    func setupCheckedView(isRight: Bool) {
        let imageName = isRight ? "checkmark.circle.fill" : "xmark.circle.fill"
        let imageColor: UIColor = isRight ? .systemGreen : .systemRed
        let borderColor: CGColor = isRight ? UIColor.systemGreen.cgColor : UIColor.systemRed.cgColor
        
        resultIconImageView.image = UIImage(systemName: imageName)
        resultIconImageView.tintColor = imageColor
        layer.borderColor = borderColor
        layer.borderWidth = 1.0
    }
    
    private func setupView() {
        layer.cornerRadius = 12.0
        layer.borderWidth = 0.4
        layer.borderColor = UIColor.separator.cgColor
        
        [
            indexLabel,
            textLabel,
            resultIconImageView
        ].forEach {
            addSubview($0)
        }
        indexLabel.snp.contentHuggingHorizontalPriority = 101.0
        textLabel.snp.contentHuggingHorizontalPriority = 100.0
        resultIconImageView.snp.contentHuggingHorizontalPriority = 101.0
        
        indexLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16.0)
        }
        textLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(indexLabel.snp.trailing).offset(8.0)
            $0.trailing.equalTo(resultIconImageView.snp.leading).inset(8.0)
        }
        resultIconImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16.0)
            $0.size.equalTo(textLabel.snp.height)
        }
    }
}
