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
    private lazy var videoVocaView = VideoVocaView(videoURLString: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4").then {
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
    var currentVideoRate: VideoRate = .default {
        didSet {
            videoVocaView.changeRate(to: currentVideoRate)
        }
    }
    var currentVideSeekTime: VideoSeekTime = .t_5 {
        didSet {
            videoVocaView.changeSeekTime(to: currentVideSeekTime)
        }
    }
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
        
        let rateAction = UIAlertAction(title: "재생 속도 \(currentVideoRate.text)", style: .default) { _ in
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            VideoRate.allCases.forEach { rate in
                let action = UIAlertAction(title: rate.text, style: .default) { _ in
                    self.currentVideoRate = rate
                }
                alert.addAction(action)
            }
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true)
        }
        let seekTimeAction = UIAlertAction(title: "구간 탐색 \(currentVideSeekTime.text)초", style: .default) { _ in
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            VideoSeekTime.allCases.forEach { seekTime in
                let action = UIAlertAction(title: seekTime.text + "초", style: .default) { _ in
                    self.currentVideSeekTime = seekTime
                }
                alert.addAction(action)
            }
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        [
            rateAction,
            seekTimeAction,
            cancelAction
        ].forEach {
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
            image: Icon.ellipsis.image,
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
        removeView(introView)
        setupView(videoVocaView)
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

extension VocaViewController: VideoVocaViewDelegate {
    func videoVocaView(videoVocaView: VideoVocaView, didEndPlayer: Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.removeView(videoVocaView)
            self.setupView(self.selectVocaView)
            self.selectVocaView.resetChoiceButtonStackView() // test
            self.selectVocaView.setupVocaQnASet()
            self.setupNavigationBarBorderBottom()
            self.navigationItem.title = "Voca \(self.selectVocaView.currentQnAIndex + 1) of \(VocaQnASet.MOCK_DATA.count)"
        }
        
    }
}
