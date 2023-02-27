//
//  ResultVocaView.swift
//  Voca
//
//  Created by yc on 2023/02/26.
//

import UIKit

import Then
import SnapKit

protocol ResultVocaViewDelegate: AnyObject {
    func resultVocaView(resultVoca: ResultVocaView, retry retryButton: UIButton)
    func resultVocaView(resultVoca: ResultVocaView, moveToNextStep nextButton: UIButton)
}
 
final class ResultVocaView: UIView, StudyModeView {
    
    let result: [VocaQnASet]
    
    weak var delegate: ResultVocaViewDelegate?
    
    init(result: [VocaQnASet]) {
        self.result = result
        super.init(frame: .zero)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.text = "학습한 내용을 확인해 보세요."
        $0.font = .systemFont(ofSize: 24.0, weight: .bold)
    }
    private lazy var resultTableView = UITableView().then {
        $0.showsVerticalScrollIndicator = false
        $0.dataSource = self
        $0.register(
            ResultVocaTableViewCell.self,
            forCellReuseIdentifier: ResultVocaTableViewCell.identifier
        )
    }
    private lazy var retryButton = AlphaButton().then {
        $0.style = .border(borderColor: .separator)
        $0.setTitle("다시하기", for: .normal)
        $0.setTitleColor(.label, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16.0, weight: .regular)
        $0.addTarget(self, action: #selector(didTapRetryButton), for: .touchUpInside)
    }
    private lazy var nextButton = AlphaButton().then {
        $0.style = .fill(backgroundColor: .systemPink)
        $0.setTitle("계속하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16.0, weight: .regular)
        $0.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
    }
    
    func setupView() {
        [
            titleLabel,
            resultTableView,
            retryButton,
            nextButton
        ].forEach {
            addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.top.equalToSuperview().inset(32.0)
        }
        
        resultTableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.top.equalTo(titleLabel.snp.bottom).offset(40.0)
        }
        
        retryButton.snp.makeConstraints {
            $0.top.equalTo(resultTableView.snp.bottom).offset(16.0)
            $0.leading.bottom.equalToSuperview().inset(16.0)
            $0.height.equalTo(48.0)
            $0.width.lessThanOrEqualTo(110.0)
        }
        
        nextButton.snp.makeConstraints {
            $0.top.equalTo(resultTableView.snp.bottom).offset(16.0)
            $0.leading.equalTo(retryButton.snp.trailing).offset(16.0)
            $0.trailing.bottom.equalToSuperview().inset(16.0)
            $0.height.equalTo(48.0)
        }
    }
}

extension ResultVocaView {
    @objc func didTapRetryButton(_ sender: UIButton) {
        delegate?.resultVocaView(resultVoca: self, retry: sender)
    }
    @objc func didTapNextButton(_ sender: UIButton) {
        delegate?.resultVocaView(resultVoca: self, moveToNextStep: sender)
    }
}

extension ResultVocaView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ResultVocaTableViewCell.identifier,
            for: indexPath
        ) as? ResultVocaTableViewCell else {
            return UITableViewCell()
        }
        
        if !result.isEmpty {
            let resultItem = result[indexPath.row]
            cell.setupData(resultItem: resultItem)
        }
        cell.selectionStyle = .none
        cell.delegate = self
        
        return cell
    }
}

extension ResultVocaView: ResultVocaTableViewCellDelegate {
    func resultVocaTableViewCell(cell: ResultVocaTableViewCell, playStandard button: UIButton) {
        cell.setupIsPlayingStandard(isPlaying: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            cell.setupIsPlayingStandard(isPlaying: false)
        }
    }
}
