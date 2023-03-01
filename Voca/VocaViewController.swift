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
    private lazy var separatorView = UIView().then {
        $0.backgroundColor = .separator
    }
    private lazy var introView = IntroView(episodeType: .voca).then {
        $0.delegate = self
    }
    private lazy var selectVocaView = SelectVocaView(vocaQnASets: VocaQnASet.MOCK_DATA).then {
        $0.delegate = self
    }
    private var resultVocaView: ResultVocaView? {
        didSet {
            if resultVocaView != nil {
                resultVocaView?.delegate = self
            }
        }
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
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let introAction = UIAlertAction(title: "인트로", style: .default) { _ in
            self.removeView(self.introView)
            self.removeView(self.selectVocaView)
            if let resultVocaView = self.resultVocaView {
                self.removeView(resultVocaView)
            }
            self.setupView(self.introView)
            self.navigationItem.title = ""
            self.separatorView.removeFromSuperview()
        }
        let selectVocaAction = UIAlertAction(title: "문제풀이", style: .default) { _ in
            self.removeView(self.introView)
            self.removeView(self.selectVocaView)
            if let resultVocaView = self.resultVocaView {
                self.removeView(resultVocaView)
            }
            self.setupView(self.selectVocaView)
            self.selectVocaView.resetChoiceButtonStackView()
            self.selectVocaView.currentQnAIndex = 0
            self.selectVocaView.setupVocaQnASet()
            self.setupNavigationBarBorderBottom()
            self.navigationItem.title = "Voca 1 of \(VocaQnASet.MOCK_DATA.count)"
        }
        let resultVocaAction = UIAlertAction(title: "결과", style: .default) { _ in
            self.removeView(self.introView)
            self.removeView(self.selectVocaView)
            if let resultVocaView = self.resultVocaView {
                self.removeView(resultVocaView)
                
            }
            self.setupView(ResultVocaView(result: VocaQnASet.MOCK_DATA))
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        [introAction, selectVocaAction, resultVocaAction, cancelAction].forEach {
            alertController.addAction($0)
        }
        
        present(alertController, animated: true)
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
        v.removeFromSuperview()
    }
}

// MARK: - Delegate Methods
extension VocaViewController: IntroViewDelegate {
    func introView(_ intro: IntroView, start didTapButton: UIButton) {
//        removeView(introView)
//        setupView(selectVocaView)
//        selectVocaView.resetChoiceButtonStackView() // test
//        selectVocaView.setupVocaQnASet()
//        setupNavigationBarBorderBottom()
//        navigationItem.title = "Voca \(selectVocaView.currentQnAIndex + 1) of \(VocaQnASet.MOCK_DATA.count)"
        
        
        removeView(introView)
        let videoView = VideoVocaView(videoURLString: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        setupView(videoView)
    }
}

extension VocaViewController: SelectVocaViewDelegate {
    func selectVocaView(selectVoca: SelectVocaView, didEnd result: [VocaQnASet]) {
        resultVocaView = ResultVocaView(result: result)
        if let resultVocaView = resultVocaView {
            removeView(selectVocaView)
            setupView(resultVocaView)
        }
    }
    
    func selectVocaView(selectVoca: SelectVocaView, moveToNextStep currentQnAIndex: Int) {
        navigationItem.title = "Voca \(currentQnAIndex + 1) of \(VocaQnASet.MOCK_DATA.count)"
    }
}

extension VocaViewController: ResultVocaViewDelegate {
    func resultVocaView(resultVoca: ResultVocaView, retry retryButton: UIButton) {
        removeView(resultVoca)
        setupView(selectVocaView)
        selectVocaView.resetChoiceButtonStackView()
        selectVocaView.currentQnAIndex = 0
        selectVocaView.setupVocaQnASet()
        navigationItem.title = "Voca \(selectVocaView.currentQnAIndex + 1) of \(VocaQnASet.MOCK_DATA.count)"
    }
    
    func resultVocaView(resultVoca: ResultVocaView, moveToNextStep nextButton: UIButton) {
        print("계속하기")
    }
}
