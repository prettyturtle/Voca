//
//  VideoVocaView.swift
//  Voca
//
//  Created by yc on 2023/03/01.
//

import UIKit
import AVKit

import Then
import SnapKit

final class VideoVocaView: UIView, StudyModeView {
    
    private let videoURLString: String
    
    init(videoURLString: String) {
        self.videoURLString = videoURLString
        super.init(frame: .zero)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var seekValue = 5.0
    
    private lazy var videoModuleView = VideoModuleView(videoURLString: videoURLString).then {
        $0.delegate = self
    }
    private lazy var videoSliderView = UISlider().then {
        $0.tintColor = .systemPink
    }
    private lazy var currentSliderValueLabel = UILabel().then {
        $0.text = "00:00"
        $0.font = .systemFont(ofSize: 16.0, weight: .medium)
    }
    private lazy var totalSliderValueLabel = UILabel().then {
        $0.text = "--:--"
        $0.font = .systemFont(ofSize: 16.0, weight: .medium)
    }
    private lazy var playButton = UIButton().then {
        $0.setImage(UIImage(systemName: "play.fill"), for: .normal)
        $0.tintColor = .label
        $0.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
    }
    private lazy var prevSeekButton = UIButton().then {
        $0.setImage(UIImage(systemName: "backward.end.fill"), for: .normal)
        $0.tintColor = .label
        $0.addTarget(self, action: #selector(didTapSeekButton), for: .touchUpInside)
    }
    private lazy var nextSeekButton = UIButton().then {
        $0.setImage(UIImage(systemName: "forward.end.fill"), for: .normal)
        $0.tintColor = .label
        $0.addTarget(self, action: #selector(didTapSeekButton), for: .touchUpInside)
    }
    private lazy var videoControlButtonStackView = UIStackView().then { stackView in
        stackView.axis = .horizontal
        stackView.spacing = 16.0
        stackView.distribution = .fillEqually
        
        [
            prevSeekButton,
            playButton,
            nextSeekButton
        ].forEach { button in
            stackView.addArrangedSubview(button)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoModuleView.setupVideoPlayer()
    }
    
    func setupView() {
        [
            videoModuleView,
            videoSliderView,
            currentSliderValueLabel,
            totalSliderValueLabel,
            videoControlButtonStackView
        ].forEach {
            addSubview($0)
        }
        
        videoModuleView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
        
        videoSliderView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.top.equalTo(videoModuleView.snp.bottom).offset(16.0)
        }
        
        currentSliderValueLabel.snp.makeConstraints {
            $0.leading.equalTo(videoSliderView.snp.leading)
            $0.top.equalTo(videoSliderView.snp.bottom).offset(8.0)
        }
        
        totalSliderValueLabel.snp.makeConstraints {
            $0.trailing.equalTo(videoSliderView.snp.trailing)
            $0.top.equalTo(videoSliderView.snp.bottom).offset(8.0)
        }
        
        videoControlButtonStackView.snp.makeConstraints {
            $0.top.equalTo(totalSliderValueLabel.snp.bottom).offset(16.0)
            $0.leading.trailing.bottom.equalToSuperview().inset(16.0)
            $0.height.equalTo(48.0)
        }
    }
}

extension VideoVocaView {
    @objc func didTapSeekButton(_ sender: UIButton) {
        if sender == prevSeekButton {
            videoModuleView.seek(to: -seekValue)
        } else if sender == nextSeekButton {
            videoModuleView.seek(to: seekValue)
        }
    }
    @objc func didTapPlayButton(_ sender: UIButton) {
        let videoStatus = videoModuleView.getStatus()
        print("비디오 재생 상태 : \(videoStatus!)")
        
        switch videoStatus {
        case .paused:
            sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            videoModuleView.play()
        case .playing:
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
            videoModuleView.pause()
        default:
            return
        }
    }
}

extension VideoVocaView: VideoModuleViewDelegate {
    func videoModuleView(moduleView: VideoModuleView?, occurAnyError: VideoModuleError) {
        print(moduleView, occurAnyError)
    }
    
    func videoModuleView(moduleView: VideoModuleView, observe currentTime: CMTime) {
        guard let duration = moduleView.getDuration() else { return }
        
        let totalTime = CMTimeGetSeconds(duration)
        let current = CMTimeGetSeconds(currentTime)
        let sliderValue = Float(current / totalTime)
        
        videoSliderView.value = sliderValue
//        currentSliderValueLabel.text = "\(current)"
    }
}
