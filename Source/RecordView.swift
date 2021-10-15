//
//  RecordView.swift
//  iRecordView
//
//  Created by Devlomi on 8/3/19.
//  Copyright © 2019 Devlomi. All rights reserved.
//

import UIKit

public class RecordView: UIView, CAAnimationDelegate {

    private var isSwiped = false
    private var bucketImageView: BucketImageView!

    private var timer: Timer?
    private var duration: CGFloat = 0
    private var mTransform: CGAffineTransform!
    private var endTransform: CGAffineTransform!
    private var audioPlayer: AudioPlayer!
    
    private var timerStackView: UIStackView!
    private var slideToCancelStackVIew: UIStackView!

    public weak var delegate: RecordViewDelegate?
    public var offset: CGFloat = 30
    public var yOffset: CGFloat = -100
    public var isSoundEnabled = true
    public var buttonTransformScale: CGFloat = 3

    private var recordButton : RecordButton?
    
    public var slideToCancelText: String! {
        didSet {
            slideLabel.text = slideToCancelText
        }
    }

    public var slideToCancelTextColor: UIColor! {
        didSet {
            slideLabel.textColor = slideToCancelTextColor
        }
    }

    public var slideToCancelArrowImage: UIImage! {
        didSet {
            arrow.image = slideToCancelArrowImage
        }
    }

    public var smallMicImage: UIImage! {
        didSet {
            bucketImageView.smallMicImage = smallMicImage
        }
    }

    public var durationTimerColor: UIColor! {
        didSet {
            timerLabel.textColor = durationTimerColor
        }
    }


    private let arrow: UIImageView = {
        let arrowView = UIImageView()
        arrowView.image = UIImage.fromPod("arrow")
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        arrowView.tintColor = UIColor(named: "Green5")
        return arrowView
    }()

    private let slideLabel: UILabel = {
        let slide = UILabel()
        slide.text = "Slide To Cancel"
        slide.translatesAutoresizingMaskIntoConstraints = false
        slide.font = slide.font.withSize(12)
        slide.textColor = UIColor(named: "Green5")
        return slide
    }()

    private var timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.font = label.font.withSize(12)
        label.textColor = UIColor(named: "Green5")
        return label
    }()

    private var lockRecorederView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.masksToBounds = false
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 5
        return view
    }()
    
    private var lockImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor(named: "Green5")
        if #available(iOS 13.0, *) {
            iv.image = UIImage(systemName: "lock")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        return iv
    }()
    
    lazy var cancelButton: UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.setTitle("Cancelar", for: .normal)
        bt.setTitleColor(UIColor(named: "Green5"), for: .normal)
//        bt.addTarget(self, action: #selector(delegate?.onCancel), for: .touchUpInside)
        bt.tintColor = UIColor(named: "Green5")
        return bt
    }()
    
    lazy var sendAudioButton: UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
//        bt.setTitle("Cancelar", for: .normal)
        if #available(iOS 13.0, *) {
            bt.setImage(UIImage(systemName: "paperplane")?.withRenderingMode(.alwaysTemplate) , for: .normal)
        } else {
            // Fallback on earlier versions
        }
        bt.setTitleColor(.black, for: .normal)
//        bt.addTarget(self, action: #selector(delegate?.onCancel), for: .touchUpInside)
        bt.tintColor = UIColor(named: "Green5")
//        bt.backgroundColor = .blue
        bt.isHidden = true
        return bt
    }()
    
    private var canSwipeLeft: Bool = true
    private var canSwipeUp: Bool = true
    
    private func setup() {
        bucketImageView = BucketImageView(frame: frame)
        bucketImageView.animationDelegate = self
        bucketImageView.translatesAutoresizingMaskIntoConstraints = false
        bucketImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        bucketImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true


        timerStackView = UIStackView(arrangedSubviews: [bucketImageView, timerLabel])
        timerStackView.translatesAutoresizingMaskIntoConstraints = false
        timerStackView.isHidden = true
        timerStackView.spacing = 5


        slideToCancelStackVIew = UIStackView(arrangedSubviews: [arrow, slideLabel])
        slideToCancelStackVIew.translatesAutoresizingMaskIntoConstraints = false
        slideToCancelStackVIew.isHidden = true


        
        addSubview(sendAudioButton)
        addSubview(cancelButton)
        addSubview(timerStackView)
        addSubview(slideToCancelStackVIew)
        addSubview(lockRecorederView)
        lockRecorederView.addSubview(lockImageView)
        


        arrow.widthAnchor.constraint(equalToConstant: 15).isActive = true
        arrow.heightAnchor.constraint(equalToConstant: 15).isActive = true

        slideToCancelStackVIew.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -60).isActive = true
        slideToCancelStackVIew.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true


        timerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        timerStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        

        //MARK: ADDED
        lockRecorederView.bottomAnchor.constraint(equalTo: self.topAnchor, constant: -20).isActive = true
        lockRecorederView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        lockRecorederView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        lockRecorederView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        lockRecorederView.isHidden = true
        
        
        lockImageView.topAnchor.constraint(equalTo: lockRecorederView.topAnchor, constant: 5).isActive = true
        lockImageView.leadingAnchor.constraint(equalTo: lockRecorederView.leadingAnchor, constant: 5).isActive = true
        lockImageView.trailingAnchor.constraint(equalTo: lockRecorederView.trailingAnchor, constant: -5).isActive = true
        lockImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        sendAudioButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        sendAudioButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendAudioButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        sendAudioButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        cancelButton.trailingAnchor.constraint(equalTo: sendAudioButton.leadingAnchor, constant: -60).isActive = true
        cancelButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        cancelButton.isHidden = true
        cancelButton.isUserInteractionEnabled = true
        
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        sendAudioButton.addTarget(self, action: #selector(didTapSendAudio), for: .touchUpInside)
        
        if #available(iOS 13.0, *) {
            lockImageView.image = UIImage(systemName: "lock")
        } else {
            // Fallback on earlier versions
        }
        mTransform = CGAffineTransform(scaleX: buttonTransformScale, y: buttonTransformScale)
        
        audioPlayer = AudioPlayer()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }


    func onTouchDown(recordButton: RecordButton) {
        onStart(recordButton: recordButton)
    }

    func onTouchUp(recordButton: RecordButton) {
        guard !isSwiped else {
            return
        }
        onFinish(recordButton: recordButton)
    }
    
    func onTouchCancelled(recordButton: RecordButton) {
        onTouchCancel(recordButton: recordButton)
    }


    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }


    @objc private func updateDuration() {
        duration += 1
        timerLabel.text = duration.fromatSecondsFromTimer()
    }

    //this will be called when user starts tapping the button
    private func onStart(recordButton: RecordButton) {
        isSwiped = false

        self.prepareToStartRecording(recordButton: recordButton)

        if isSoundEnabled {
            audioPlayer.playAudioFile(soundType: .start)
            audioPlayer.didFinishPlaying = { [weak self] _ in
                self?.delegate?.onStart()
            }
        } else {
            delegate?.onStart()
        }
    }
    
    private func prepareToStartRecording(recordButton: RecordButton) {
        resetTimer()

        //start timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateDuration), userInfo: nil, repeats: true)


        //reset all views to default
        slideToCancelStackVIew.transform = .identity
        lockRecorederView.transform = .identity
        recordButton.transform = CGAffineTransform(scaleX: 1, y: 1)

        //animate button to scale up
        UIView.animate(withDuration: 0.2) {
            recordButton.transform = self.mTransform
        }


        slideToCancelStackVIew.isHidden = false
        lockRecorederView.isHidden = false
        timerStackView.isHidden = false
        timerLabel.isHidden = false
        bucketImageView.isHidden = false
        bucketImageView.resetAnimations()
        bucketImageView.animateAlpha()
    }

    fileprivate func animateRecordButtonToIdentity(_ recordButton: RecordButton) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            recordButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
    
    //this will be called when user swipes to the left and cancel the record
    fileprivate func hideCancelStackViewAndTimeLabel() {
        slideToCancelStackVIew.isHidden = true
        lockRecorederView.isHidden = true
        timerLabel.isHidden = true
        lockRecorederView.isHidden = true
    }
    
    private func onSwipe(recordButton: RecordButton) {
        print("cancelled")
        isSwiped = true
        audioPlayer.didFinishPlaying = nil
        cancelButton.isHidden = true
        sendAudioButton.isHidden = true
        
        animateRecordButtonToIdentity(recordButton)

        hideCancelStackViewAndTimeLabel()

        if !isLessThanOneSecond() {
            bucketImageView.animateBucketAndMic()

        } else {
            bucketImageView.isHidden = true
            delegate?.onAnimationEnd?()
        }

        resetTimer()

        delegate?.onCancel()
    }
    
    @objc func didTapCancelButton(){
        print("tapped")
        isSwiped = false
        audioPlayer.didFinishPlaying = nil
        cancelButton.isHidden = true
        sendAudioButton.isHidden = true
        
        hideCancelStackViewAndTimeLabel()

        if !isLessThanOneSecond() {
            bucketImageView.animateBucketAndMic()

        } else {
            bucketImageView.isHidden = true
            delegate?.onAnimationEnd?()
        }
        resetTimer()
        delegate?.onCancel()
    }
    
    @objc func didTapSendAudio(){
        print("tapped")
        
//        guard let recordBtn = self.recordButton else {return}
////        onFinish(recordButton: recordBtn)
//        isSwiped = false
//        audioPlayer.didFinishPlaying = nil
//        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
//            recordBtn.transform = CGAffineTransform(scaleX: 1, y: 1)
//        })


        slideToCancelStackVIew.isHidden = true
        lockRecorederView.isHidden = true
        timerStackView.isHidden = true
        cancelButton.isHidden = true
        sendAudioButton.isHidden = true

        timerLabel.isHidden = true


        if isLessThanOneSecond() {
            if isSoundEnabled {
                audioPlayer.playAudioFile(soundType: .error)
            }
        } else {
            if isSoundEnabled {
                audioPlayer.playAudioFile(soundType: .end)
            }
        }

        delegate?.onFinished(duration: duration)

        resetTimer()
        
    }
    
    private func onSwipeUp(recordButton: RecordButton) {
        print("entered here 2")
        isSwiped = true
        lockRecorederView.isHidden = true
        slideToCancelStackVIew.isHidden = true
        cancelButton.isHidden = false
        sendAudioButton.isHidden = false
        
        animateRecordButtonToIdentity(recordButton)
        
        delegate?.didSwipeToLock()
    }
    
    private func onTouchCancel(recordButton: RecordButton) {
        //MARK: This is called
        isSwiped = false
        
        audioPlayer.didFinishPlaying = nil
        
        animateRecordButtonToIdentity(recordButton)
        
        hideCancelStackViewAndTimeLabel()
        
        bucketImageView.isHidden = true
        delegate?.onAnimationEnd?()
        
        resetTimer()
        
        delegate?.onCancel()
    }

    private func resetTimer() {
        timer?.invalidate()
        timerLabel.text = "00:00"
        duration = 0
        canSwipeLeft = true
        canSwipeUp = true
    }

    //this will be called when user lift his finger
    private func onFinish(recordButton: RecordButton) {
        isSwiped = false
        audioPlayer.didFinishPlaying = nil
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            recordButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        })


        slideToCancelStackVIew.isHidden = true
        lockRecorederView.isHidden = true
        timerStackView.isHidden = true
        cancelButton.isHidden = true
        sendAudioButton.isHidden = true

        timerLabel.isHidden = true


        if isLessThanOneSecond() {
            if isSoundEnabled {
                audioPlayer.playAudioFile(soundType: .error)
            }
        } else {
            if isSoundEnabled {
                audioPlayer.playAudioFile(soundType: .end)
            }
        }

        delegate?.onFinished(duration: duration)

        resetTimer()

    }

    //this will be called when user starts to move his finger
    func touchMoved(recordButton: RecordButton, sender: UIPanGestureRecognizer) {

        guard !isSwiped else {
            return
        }

        let button = sender.view!
        let translation = sender.translation(in: button)

        switch sender.state {
        case .changed:

            //prevent swiping the button outside the bounds
            if translation.x < 0 {
                
                canSwipeUp = false
                //start move the views
                
                
                let transform = mTransform.translatedBy(x: translation.x, y: 0)
                button.transform = transform
                slideToCancelStackVIew.transform = transform.scaledBy(x: 0.5, y: 0.5)
                
                
                if slideToCancelStackVIew.frame.intersects(timerStackView.frame.offsetBy(dx: offset, dy: 0)) {
                    button.transform = mTransform.translatedBy(x: 1, y: 1)
                    onSwipe(recordButton: recordButton)
                }
                
            }
            
            if translation.y < 0 {
                canSwipeLeft = false
                //start move the views

                let transform = mTransform.translatedBy(x: 0, y: translation.y)
                button.transform = transform
                lockRecorederView.transform = transform.scaledBy(x: 0.5, y: 0.5)
                if button.frame.intersects(timerStackView.frame.offsetBy(dx: 0, dy: yOffset)) {
                    button.transform = mTransform.translatedBy(x: 1, y: 1)
                    print("entered here")
                    self.recordButton = recordButton
                    onSwipeUp(recordButton: recordButton)
                }
            }
            
        case .ended:
            button.transform = mTransform.translatedBy(x: 1, y: 1)
            
        default:
            break
        }

    }
   

}



extension RecordView: AnimationFinishedDelegate {
    func animationFinished() {
        slideToCancelStackVIew.isHidden = true
        lockRecorederView.isHidden = true
        timerStackView.isHidden = false
        timerLabel.isHidden = true
        delegate?.onAnimationEnd?()
    }
}

private extension RecordView {
    func isLessThanOneSecond() -> Bool {
        return duration < 1
    }
}

