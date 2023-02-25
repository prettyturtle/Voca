//
//  VocaViewController.swift
//  Voca
//
//  Created by yc on 2023/02/25.
//

import UIKit

import Then
import SnapKit

final class VocaViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var introView = IntroView(episodeType: .voca).then {
        $0.delegate = self
    }
    private lazy var selectVocaView = SelectVocaView(vocaQnASets: VocaQnASet.MOCK_DATA).then {
        $0.delegate = self
    }
    
    // MARK: - Properties
    
}

// MARK: - Life Cycle
extension VocaViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Main Methods
extension VocaViewController {
    @objc func didTapSettingBarButton() {
        selectVocaView.currentQnAIndex = 0
        navigationItem.title = "Voca \(selectVocaView.currentQnAIndex + 1) of \(VocaQnASet.MOCK_DATA.count)"
        selectVocaView.resetChoiceButtonStackView()
        selectVocaView.setupVocaQnASet()
    }
}

// MARK: - UI Methods
extension VocaViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground
        setupNavigationBarButton()
        setupView(introView)
    }
    func setupNavigationBarButton() {
        let settingBarButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(didTapSettingBarButton)
        )
        settingBarButton.tintColor = .label
        
        navigationItem.rightBarButtonItem = settingBarButton
    }
    func setupNavigationBarBorderBottom() {
        let separatorView = UIView().then {
            $0.backgroundColor = .separator
        }
        navigationController?.navigationBar.addSubview(separatorView)
        separatorView.snp.makeConstraints {
            $0.height.equalTo(0.4)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    func setupView(_ v: StudyModeView) {
        guard let v = v as? UIView else { return }
        view.addSubview(v)
        
        v.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    func removeView(_ v: StudyModeView) {
        guard let v = v as? UIView else { return }
        view.willRemoveSubview(v)
    }
}

// MARK: - Delegate Methods
extension VocaViewController: IntroViewDelegate {
    func introView(_ intro: IntroView, start didTapButton: UIButton) {
        removeView(introView)
        setupView(selectVocaView)
        selectVocaView.setupVocaQnASet()
        setupNavigationBarBorderBottom()
        navigationItem.title = "Voca \(selectVocaView.currentQnAIndex + 1) of \(VocaQnASet.MOCK_DATA.count)"
    }
}
extension VocaViewController: SelectVocaViewDelegate {
    func selectVocaView(selectVoca: SelectVocaView, didEnd results: [VocaQnASet]) {
        print(results)
    }
    
    func selectVocaView(selectVoca: SelectVocaView, moveToNextStep currentQnAIndex: Int) {
        navigationItem.title = "Voca \(currentQnAIndex + 1) of \(VocaQnASet.MOCK_DATA.count)"
    }
}
