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
    var pauseFlg    :Bool      = false
    var musicPlayer            = MPMusicPlayerController()
    var status      :Int       = Status().prepare
    var currentTime :CGFloat   = 0
    var prepareCouter :CGFloat = 0
    var workOutCounter:CGFloat = 0
    var restCounter   :CGFloat = 0
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
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
        
        musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
        musicPlayer.beginGeneratingPlaybackNotifications()
        
        //グラフのレイアウトを設定
        setupGraph()
        //カウンターの数値を初期化
        resetAll()
        //カウンターの数値をカスタマイズ用
        setupPicker()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - setup
    
    //グラフのサイズ/レイアウト/ポジションの設定
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
        
        setGraph.frame.size = CGSize(width: 60, height: 60)
        titleLabel.center.x = self.view.center.x
        
        /*layout*/
        prepareGraph.tag = 1
        prepareGraph.value = ceil(Settings().workOutTime)
        prepareGraph.maxValue = Settings().workOutTime
        prepareGraph.valueFontSize = 50
        prepareGraph.progressAngle = 100
        prepareGraph.progressLineWidth = 4
        prepareGraph.emptyLineWidth = 4
        prepareGraph.unitString = DisplayString().unit
        prepareGraph.unitFontSize = 20
        prepareGraph.progressCapType = 0
        prepareGraph.progressRotationAngle = 0
        prepareGraph.fontColor = Color().fontColor
        prepareGraph.progressColor = Color().red
        prepareGraph.progressStrokeColor = Color().red
        prepareGraph.emptyLineColor = UIColor.gray
        
        restGraph.tag = 2
        restGraph.value = ceil(Settings().restTime)
        restGraph.maxValue = Settings().restTime
        restGraph.valueFontSize = 50
        restGraph.progressAngle = 100
        restGraph.progressLineWidth = 4
        restGraph.emptyLineWidth = 4
        restGraph.unitString = DisplayString().unit
        restGraph.unitFontSize = 20
        restGraph.progressCapType = 0
        restGraph.progressRotationAngle = 0
        restGraph.fontColor = Color().fontColor
        restGraph.progressColor = Color().blue
        restGraph.progressStrokeColor = Color().blue
        restGraph.emptyLineColor = UIColor.gray
        
        workOutGraph.tag = 3
        workOutGraph.value = ceil(Settings().restTime)
        workOutGraph.maxValue = Settings().restTime
        workOutGraph.valueFontSize = 50
        workOutGraph.progressAngle = 100
        workOutGraph.progressLineWidth = 4
        workOutGraph.emptyLineWidth = 4
        workOutGraph.unitString = DisplayString().unit
        workOutGraph.unitFontSize = 20
        workOutGraph.progressCapType = 0
        workOutGraph.progressRotationAngle = 0
        workOutGraph.fontColor = Color().fontColor
        workOutGraph.progressColor = Color().yellow
        workOutGraph.progressStrokeColor = Color().yellow
        workOutGraph.emptyLineColor = UIColor.gray
        
        setGraph.tag = 4
        setGraph.value = ceil( CGFloat(Settings().setCounter))
        setGraph.maxValue = ceil( CGFloat(Settings().setCounter))
        setGraph.valueFontSize = 20
        setGraph.progressAngle = 100
        setGraph.progressLineWidth = 2
        setGraph.unitString = DisplayString().unit
        setGraph.emptyLineWidth = 2
        setGraph.unitFontSize = 10
        setGraph.progressCapType = 0
        setGraph.progressRotationAngle = 0
        setGraph.fontColor = Color().fontColor
        setGraph.progressColor = Color().orange
        setGraph.progressStrokeColor = Color().orange
        setGraph.emptyLineColor = UIColor.gray
        
        totalGraph.tag = 5
        totalGraph.value = ceil( CGFloat(Settings().endTime) )
        totalGraph.maxValue = CGFloat(Settings().endTime)
        totalGraph.valueFontSize = 20
        totalGraph.progressAngle = 100
        totalGraph.progressLineWidth = 2
        totalGraph.unitString = DisplayString().unit
        totalGraph.emptyLineWidth = 2
        totalGraph.unitFontSize = 10
        totalGraph.progressCapType = 0
        totalGraph.progressRotationAngle = 0
        totalGraph.fontColor = Color().fontColor
        totalGraph.progressColor = Color().orange
        totalGraph.progressStrokeColor = Color().orange
        totalGraph.emptyLineColor = UIColor.gray
        
        /*Position*/
        //ここらへん全部わからん
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
        
        //なぜ-1?
        currentTime = -1
        status = Status().prepare
        pauseFlg = false
        
        titleLabel.text = TitleText().title
        titleLabel.textColor = UIColor.darkGray
        
        prepareCouter = Settings().prepareTime
        workOutCounter = Settings().workOutTime
        restCounter = Settings().restTime
        
        angleHolder = 0
        turnBaseView(ang: angleHolder)
        turnTimerView(subview: prepareGraph, ang: -angleHolder, scale: Scale().comeFront)
        turnTimerView(subview: workOutGraph, ang: -angleHolder, scale: Scale().goBack)
        turnTimerView(subview: restGraph, ang: -angleHolder, scale: Scale().goBack)
        
        stopButton.isHidden = true
        pauseButton.isHidden = true
        startButton.isHidden = false
        
    }
    
    //グラフのカウンターをカスタマイズする時に使用するpicker
    func setupPicker() {
       //処理
    }
    
    // MARK: - Button action
    
    @IBAction func startTimer(_ sender: AnyObject) {
        
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
        
        if !pauseFlg {
            status = Status().prepare
            
            titleLabel.text = "READY"
            titleLabel.textColor = UIColor.yellow
//            titleLabel.animation = "fadeInLeft"
//            titleLabel.duration = Duration.startTitleDuration
//            titleLabel.animate()
            
        } else {
            
        }
        
    }
    
    func onUpdate(timer:Timer) {
        
    }
    
    func turnBaseView(ang:CGFloat) {
        
    }
    
    func turnTimerView(subview:UIView, ang:CGFloat, scale:CGFloat) {
        
    }
    
    
}

