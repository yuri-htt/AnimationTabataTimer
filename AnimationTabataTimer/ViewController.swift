//
//  ViewController.swift
//  WorkOutTimer
//
//  Created by 田山　由理 on 2016/11/28.
//  Copyright © 2016年 Yuri Tayama. All rights reserved.
//

import UIKit
import MBCircularProgressBar
import AVFoundation
import Spring
import MediaPlayer

class ViewController: UIViewController {
    
    let talker                 = AVSpeechSynthesizer()
    var timer       :Timer     = Timer()
    var angleHolder :CGFloat   = 0
    var isPause    :Bool      = false//消したい
    var status      :Status    = .prepare
    var currentTime :CGFloat   = 0
    var prepareCounter:CGFloat = 0
    var workOutCounter:CGFloat = 0
    var restCounter   :CGFloat = 0
    
    @IBOutlet weak var titleLabel: SpringLabel!
    
    @IBOutlet weak var baseTurnView: UIView!
    
    @IBOutlet weak var restAnimView: SpringView!
    @IBOutlet weak var prepareAnimView: SpringView!
    @IBOutlet weak var workOutAnimView: SpringView!
    
    @IBOutlet weak var restGraph: MBCircularProgressBarView!
    @IBOutlet weak var prepareGraph: MBCircularProgressBarView!
    @IBOutlet weak var workOutGraph: MBCircularProgressBarView!
    @IBOutlet weak var setGraph: MBCircularProgressBarView!
    @IBOutlet weak var totalGraph: MBCircularProgressBarView!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //グラフのレイアウトを設定
        setupGraph()
        //カウンターの数値を初期化
        resetAll()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - setup methods
    // グラフのサイズ/レイアウト/ポジションの設定
    func setupGraph() {
        
        /*Size*/
        baseTurnView.frame.size = CGSize(width: UIScreen.main.bounds.size.height * 0.55, height: UIScreen.main.bounds.size.height * 0.55 )
        baseTurnView.center.x = self.view.center.x
        
        workOutAnimView.frame.size = CGSize(width:baseTurnView.frame.size.width * 0.7, height: baseTurnView.frame.size.height * 0.7 )
        workOutGraph.frame.size = workOutAnimView.frame.size
        
        prepareAnimView.frame.size = CGSize(width:baseTurnView.frame.size.width * 0.7, height: baseTurnView.frame.size.height * 0.7 )
        prepareGraph.frame.size = prepareAnimView.frame.size
        
        restAnimView.frame.size = CGSize(width:baseTurnView.frame.size.width * 0.7, height: baseTurnView.frame.size.height * 0.7 )
        restGraph.frame.size = restAnimView.frame.size
        
        titleLabel.center.x = self.view.center.x
        
        /*layout*/
        prepareGraph.value = ceil(Settings().prepareTime)
        prepareGraph.maxValue = Settings().prepareTime
        
        restGraph.value = ceil(Settings().restTime)
        restGraph.maxValue = Settings().restTime
        
        workOutGraph.value = ceil(Settings().workOutTime)
        workOutGraph.maxValue = Settings().workOutTime
        //workOutGraph.fontColor = Color().fontColor
        //workOutGraph.progressColor = Color().forWorkOut
        //workOutGraph.progressStrokeColor = Color().forWorkOut
        //workOutGraph.emptyLineColor = UIColor.gray
        
        setGraph.value = ceil( CGFloat(Settings().setCounter))
        setGraph.maxValue = ceil( CGFloat(Settings().setCounter))
        
        totalGraph.value = ceil( CGFloat(Settings().endTime) )
        totalGraph.maxValue = CGFloat(Settings().endTime)
        
        /*Position*/
        let radius:CGFloat = baseTurnView.layer.bounds.width/3

        let workOutRadian:CGFloat = -30 * CGFloat(M_PI) / 180
        let workOutX = cos(workOutRadian) * radius
        let workOutY = sin(workOutRadian) * radius
        workOutAnimView.layer.position = CGPoint(
            x: baseTurnView.bounds.width / 2 + workOutX,
            y: baseTurnView.bounds.height / 2 + workOutY)
        
        let prepareRadian:CGFloat = -270 * CGFloat(M_PI) / 180
        let prepareX = cos(prepareRadian) * radius
        let prepareY = sin(prepareRadian) * radius
        prepareAnimView.layer.position = CGPoint(
            x: baseTurnView.bounds.width / 2 + prepareX,
            y: baseTurnView.bounds.height / 2 + prepareY)
        
        let restRadian = -150 * CGFloat(M_PI) / 180
        let restX = cos(restRadian) * radius
        let restY = sin(restRadian) * radius
        restAnimView.layer.position = CGPoint(
            x: baseTurnView.bounds.width / 2 + restX,
            y: baseTurnView.bounds.height / 2 + restY)
        
    }
    
    //カウンターの数値＆グラフの位置の初期化/ボタン
    func resetAll() {
        
        currentTime = -1
        status = Status.prepare
        isPause = false
        
        titleLabel.text = TitleText().title
        titleLabel.textColor = UIColor.darkGray
        
        prepareCounter = Settings().prepareTime
        prepareGraph.value = prepareCounter
        workOutCounter = Settings().workOutTime
        workOutGraph.value = workOutCounter
        restCounter = Settings().restTime
        restGraph.value = restCounter
        totalGraph.value = ceil((Settings().endTime))
        
        angleHolder = 0
        turnBaseView(ang: angleHolder)
        turnTimerView(subview: prepareGraph, ang: -angleHolder, scale: Scale().comeFront)
        turnTimerView(subview: workOutGraph, ang: -angleHolder, scale: Scale().goBack)
        turnTimerView(subview: restGraph, ang: -angleHolder, scale: Scale().goBack)
        
        stopButton.isHidden = true
        pauseButton.isHidden = true
        startButton.isHidden = false
        
    }

    // MARK: - Button action
    @IBAction func didPressStartButton(_ sender: AnyObject) {
        
        //【AVSpeechUtterance】
        // - iOS7で追加された音声読み上げライブラリ
        // - http://dev.classmethod.jp/smartphone/iphone/swfit-avspeechsynthesizer/
        
        let utterance = AVSpeechUtterance(string: "Ready")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        talker.speak(utterance)
        
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(Duration().TimerUpdateDuration), target:self, selector:#selector(self.onUpdate), userInfo:nil, repeats:true)
        timer.fire()
        
        prepareAnimView.animation = "morph"
        prepareAnimView.duration = CGFloat(Duration().prepareAnimDuration)
        prepareAnimView.animate()
        
        turnBaseView(ang: angleHolder)
        turnTimerView(subview: workOutGraph, ang: -angleHolder, scale: CGFloat(Scale().goBack))
        turnTimerView(subview: prepareGraph, ang: -angleHolder, scale: CGFloat(Scale().comeFront))
        turnTimerView(subview: restGraph, ang: -angleHolder, scale: CGFloat(Scale().goBack))
        
        startButton.isHidden = true
        stopButton.isHidden = false
        pauseButton.isHidden = false
        
        if isPause {
            status = Status.prepare
            
            titleLabel.text = TitleText().ready
            titleLabel.textColor = UIColor.yellow
            titleLabel.animation = "fadeInLeft"
            titleLabel.duration = CGFloat(Duration().startTitleDuration)
            titleLabel.animate()
            
        }
        
    }
    
    @IBAction func didPressPuaseButton(_ sender: AnyObject) {
        
        if !isPause {
            
            timer.invalidate()
            isPause = true
            pauseButton.setImage(UIImage(named:"PauseStart"), for: UIControlState.normal)
            
        } else {
            
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(Duration().TimerUpdateDuration), target: self, selector: #selector(self.onUpdate), userInfo: nil, repeats: true)
            timer.fire()
            isPause = false
            pauseButton.setImage(UIImage(named:"Pause"), for: UIControlState.normal)
            
        }
        
    }
    
    @IBAction func didPressStopButton(_ sender: AnyObject) {
        
        timer.invalidate()
        resetAll()
        
        prepareAnimView.animation = "pop"
        prepareAnimView.duration = 1.0
        prepareAnimView.animate()
        workOutAnimView.animation = "pop"
        workOutAnimView.duration = 1.0
        workOutAnimView.animate()
        restAnimView.animation = "pop"
        restAnimView.duration = 1.0
        restAnimView.animate()
        
        startButton.isHidden = false
        
    }
    
    // MARK: - methods
    //一時停止＆スタート時に呼び出される
    func onUpdate(timer:Timer) {
        
        //止めたタイムを開始する際に１秒巻き戻す
        currentTime = currentTime + Duration().TimerUpdateDuration
        totalGraph.value = ceil(Settings().endTime - currentTime)
        
        switch status {
        case .prepare:
            prepareCounter = prepareCounter - Duration().TimerUpdateDuration
            if prepareCounter < 0 {
                prepareCounter = 0
            }
            prepareGraph.value = ceil(prepareCounter)
        case .rest:
            restCounter = restCounter - Duration().TimerUpdateDuration
            if restCounter < 0 {
                restCounter = 0
            }
            restGraph.value = ceil(restCounter)
        case .workOut:
            workOutCounter = workOutCounter - Duration().TimerUpdateDuration
            if workOutCounter < 0 {
                workOutCounter = 0
            }
            workOutGraph.value = ceil(workOutCounter)
        default:
            break
        }
        
        /*-*/
        if prepareCounter <= 0 {
            
            status = Status.workOut
            
            prepareCounter = Settings().prepareTime
            prepareGraph.value = ceil(prepareCounter)
            
            workOutAnimView.animation = "morph"
            workOutAnimView.duration = 1.0
            workOutAnimView.animate()
            
            titleLabel.text = "START WORKOUT"
            titleLabel.textColor = Color().red
            titleLabel.animation = "fadeInLeft"
            titleLabel.duration = 1.0
            titleLabel.animate()
            
            let utterance = AVSpeechUtterance(string: "Start workout!")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            talker.speak(utterance)
            
            angleHolder = angleHolder + 120
            turnBaseView(ang: angleHolder)
            turnTimerView(subview:workOutGraph, ang: -angleHolder,scale: 1.0)
            turnTimerView(subview:prepareGraph, ang: -angleHolder,scale: 0.5)
            turnTimerView(subview:restGraph, ang: -angleHolder,scale: 0.5)
            
        } else if restCounter <= 0 {
            
            status = Status.workOut
            
            restCounter = Settings().restTime
            restGraph.value = ceil(restCounter)
            
            workOutAnimView.animation = "morph"
            workOutAnimView.duration = 1.0
            workOutAnimView.animate()
            
            if currentTime >= Settings().endTime {
                //終了時は何もしない
            } else {
                titleLabel.text = "START WORKOUT"
                titleLabel.textColor = Color().red
                titleLabel.animation = "fadeInLeft"
                titleLabel.duration = 1.0
                titleLabel.animate()
            }
            
            let utterance = AVSpeechUtterance(string: "Start workout!")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            talker.speak(utterance)
            
            angleHolder = angleHolder - 120
            turnBaseView(ang: angleHolder)
            turnTimerView(subview:workOutGraph, ang: -angleHolder,scale: 1.0)
            turnTimerView(subview:prepareGraph, ang: -angleHolder,scale: 0.5)
            turnTimerView(subview:restGraph, ang: -angleHolder,scale: 0.5)
            
        } else if workOutCounter <= 0 {
            
            status = Status.rest
            
            workOutCounter = Settings().workOutTime
            workOutGraph.value = ceil(workOutCounter)
            
            restAnimView.animation = "morph"
            restAnimView.duration = 1.0
            restAnimView.animate()
            
            if currentTime >= Settings().endTime {
                //終了時は何もしない
            } else {
                titleLabel.text = "INTERVAL"
                titleLabel.textColor = Color().blue
                titleLabel.animation = "fadeInLeft"
                titleLabel.duration = 1.0
                titleLabel.animate()
            }
            
            let utterance = AVSpeechUtterance(string: "Interval.")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            talker.speak(utterance)
            
            angleHolder = angleHolder + 120
            turnBaseView(ang: angleHolder)
            turnTimerView(subview:workOutGraph, ang: -angleHolder,scale: 0.5)
            turnTimerView(subview:prepareGraph, ang: -angleHolder,scale: 0.5)
            turnTimerView(subview:restGraph, ang: -angleHolder,scale: 1.0)
            
        }
        
        /*CountDownVoice*/
        //カウントダウン音声
        
        if( workOutCounter == 5 ||  restCounter == 5 || prepareCounter == 5 ){

            let utterance = AVSpeechUtterance(string: "5")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            talker.speak(utterance)
            
        }else if( workOutCounter == 4 ||  restCounter == 4 || prepareCounter == 4 ){
            
            let utterance = AVSpeechUtterance(string: "4")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            talker.speak(utterance)
            
        }else if( workOutCounter == 3 ||  restCounter == 3 || prepareCounter == 3 ){
            
            let utterance = AVSpeechUtterance(string: "3")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            talker.speak(utterance)
            
        }else if( workOutCounter == 2 ||  restCounter == 2 || prepareCounter == 2 ){
            
            let utterance = AVSpeechUtterance(string: "2")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            talker.speak(utterance)
            
        }else if( workOutCounter == 1 ||  restCounter == 1 || prepareCounter == 1 ){
            
            let utterance = AVSpeechUtterance(string: "1")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            talker.speak(utterance)
            
        }
        
        /*終了処理*/
        if currentTime >= Settings().endTime {
            timer.invalidate()
            
            resetAll()
            workOutAnimView.animation = "pop"
            workOutAnimView.duration = 1.0
            workOutAnimView.animate()
            prepareAnimView.animation = "pop"
            prepareAnimView.duration = 1.0
            prepareAnimView.animate()
            restAnimView.animation = "pop"
            restAnimView.duration = 1.0
            restAnimView.animate()
            
            startButton.isHidden = false
            
            let utterance = AVSpeechUtterance(string: "Good job!")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            talker.speak(utterance)
        }
    }
    
    func turnBaseView(ang:CGFloat) {
        
        //M_PI / 180 = 1°のラジアン角
        //M_PIは半円に相当
        let angle = CGFloat(M_PI) / 180 * ang
        
        UIView.animate(withDuration: 1.0,
                       animations: { () -> Void in
                            self.baseTurnView.transform = CGAffineTransform(rotationAngle: angle)
                       }, completion: { (Bool) -> Void in
                       })
    }
    
    func turnTimerView(subview:UIView, ang:CGFloat, scale:CGFloat) {
        
        let angle = CGFloat(M_PI) / 180 * ang
        
        UIView.animate(withDuration: 1.0,
                       animations: { () -> Void in
                            // 回転用のアフィン行列を生成.
                            let t1 = CGAffineTransform(rotationAngle: angle )
                            let t2 = CGAffineTransform(scaleX: scale, y: scale)
                        
                            //concatenating:連結の意
                            subview.transform = t1.concatenating(t2)
                       },
                       completion: { (Bool) -> Void in
        })
    }
    
    func readAloud(
}

