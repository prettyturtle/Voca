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

protocol VideoVocaViewDelegate: AnyObject {
    func videoVocaView(videoVocaView: VideoVocaView, didEndPlayer: Void)
}

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
    weak var delegate: VideoVocaViewDelegate?
    
    private lazy var videoModuleView = VideoModuleView(videoURLString: videoURLString).then {
        $0.setupVideoPlayer()
        $0.play()
        $0.pause()
        $0.delegate = self
    }
    private lazy var videoSliderView = UISlider().then {
        $0.tintColor = .systemPink
        $0.addTarget(self, action: #selector(changeSliderValue), for: .valueChanged)
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
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        videoModuleView.setupVideoPlayerLayer()
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
    func changeRate(to: VideoRate) {
        videoModuleView.avPlayer?.rate = to.value
        
        // TODO: - rate 변경시 재생되는 이슈 수정
    }
    
    func changeSeekTime(to: VideoSeekTime) {
        seekValue = to.value
    }
}

extension VideoVocaView {
    @objc func changeSliderValue(_ sender: UISlider) {
        guard let duration = videoModuleView.getDuration() else { return }
        
        let value = Float64(sender.value) * CMTimeGetSeconds(duration)
        let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
        
        videoModuleView.seek(to: seekTime)
    }
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
        
        let secondsString = String(format: "%02d", Int(current) % 60)
        let miniteString = String(format: "%02d", Int(current) / 60)
        
        videoSliderView.value = sliderValue
        currentSliderValueLabel.text = "\(miniteString):\(secondsString)"
        
        if !totalTime.isNaN {
            let totalSecondsString = String(format: "%02d", Int(totalTime) % 60)
            let totalMiniteString = String(format: "%02d", Int(totalTime) / 60)
            totalSliderValueLabel.text = "\(totalMiniteString):\(totalSecondsString)"
        }
    }
    
    func videoModuleView(moduleView: VideoModuleView, didEndPlayer: Void) {
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        delegate?.videoVocaView(videoVocaView: self, didEndPlayer: ())
    }
}
