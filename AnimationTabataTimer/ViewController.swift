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
    
    let talker = AVSpeechSynthesizer()
    var timer = Timer()
    var angleHolder:CGFloat = 0
    var pauseFlg = false
    var musicPlayer = MPMusicPlayerController()
    var status = Status().prepare
    
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
        
        graphInit()
        resetAll()
        
        setUpTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func graphInit() {
        
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
        
        /*Graph layout*/
        prepareGraph.tag = 1
        prepareGraph.value = ceil(Settings().workOutTime)
        prepareGraph.maxValue = Settings().workOutTime
        prepareGraph.valueFontSize = 50
        prepareGraph.progressAngle = 100
        prepareGraph.progressLineWidth = 4
        prepareGraph.emptyLineWidth = 4
        prepareGraph.unitString = String().unit
        prepareGraph.unitFontSize = 20
        prepareGraph.progressCapType = 0
        prepareGraph.progressRotationAngle = 0
        prepareGraph.fontColor = Color().fontColor
        prepareGraph.progressColor = Color().red
        prepareGraph.progressStrokeColor = Color().red
        prepareGraph.emptyLineColor = Color().gray
        
        restGraph.tag = 2
        restGraph.value = ceil(Settings().restTime)
        restGraph.maxValue = Settings().restTime
        restGraph.valueFontSize = 50
        restGraph.progressAngle = 100
        restGraph.progressLineWidth = 4
        restGraph.emptyLineWidth = 4
        restGraph.unitString = String().unit
        restGraph.unitFontSize = 20
        restGraph.progressCapType = 0
        restGraph.progressRotationAngle = 0
        restGraph.fontColor = Color().fontColor
        restGraph.progressColor = Color().blue
        restGraph.progressStrokeColor = Color().blue
        restGraph.emptyLineColor = Color().gray
        
        workOutGraph.tag = 3
        workOutGraph.value = ceil(Settings().restTime)
        workOutGraph.maxValue = Settings().restTime
        workOutGraph.valueFontSize = 50
        workOutGraph.progressAngle = 100
        workOutGraph.progressLineWidth = 4
        workOutGraph.emptyLineWidth = 4
        workOutGraph.unitString = String().unit
        workOutGraph.unitFontSize = 20
        workOutGraph.progressCapType = 0
        workOutGraph.progressRotationAngle = 0
        workOutGraph.fontColor = Color().fontColor
        workOutGraph.progressColor = Color().yellow
        workOutGraph.progressStrokeColor = Color().yellow
        workOutGraph.emptyLineColor = Color().gray
        
        setGraph.tag = 4
        setGraph.value = ceil( CGFloat(Settings().setCounter))
        setGraph.maxValue = ceil( CGFloat(Settings().setCounter))
        setGraph.valueFontSize = 20
        setGraph.progressAngle = 100
        setGraph.progressLineWidth = 2
        setGraph.unitString = ""//Design().unitString
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
        totalGraph.unitString = ""//Design().unitString
        totalGraph.emptyLineWidth = 2
        totalGraph.unitFontSize = 10
        totalGraph.progressCapType = 0
        totalGraph.progressRotationAngle = 0
        totalGraph.fontColor = Color().fontColor
        totalGraph.progressColor = Color().orange
        totalGraph.progressStrokeColor = Color().orange
        totalGraph.emptyLineColor = UIColor.gray
        
        /*Graph position*/
        //
        //
        
    }
    
    func resetAll() {
        
    }
    
    func setUpTimer() {
        
    }
    
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

struct Duration {
    let TimerUpdateDuration = 1.0
    let prepareAnimDuration = 1.0
    let startTitleDuration = 1.0
}

struct Scale {
    let comeFront = 1.0
    let goBack = 0.5
}

struct Status {
    let prepare = 1
    let rest    = 2
    let workOut = 3
    let pause   = 4
    let others  = 0
}

struct Settings {
    var workOutTime:CGFloat = 20
    var prepareTime:CGFloat = 10
    var restTime:CGFloat = 10
    var setCounter:CGFloat = 8
    var endTime:CGFloat
    
    init() {
        endTime = prepareTime + ( workOutTime + restTime ) * setCounter - restTime
    }
}

struct String {
    var unit = "Sec"
}

struct Color {
    var fontColor = Formatter().colorWithHexString(hex: "6F7179", Alpha: 1.0 )
    let yellow:UIColor = Formatter().colorWithHexString(hex: "B9AD1E", Alpha: 1.0)
    let red:UIColor = Formatter().colorWithHexString(hex: "CC2D62", Alpha: 1.0)
    let blue:UIColor = Formatter().colorWithHexString(hex: "2D8CDD", Alpha: 1.0)
    let green:UIColor = Formatter().colorWithHexString(hex: "70BF41", Alpha: 1.0)
    let orange:UIColor = Formatter().colorWithHexString(hex: "F39019", Alpha: 1.0)
}

class Formatter {
    //hex:16進数
    func colorWithHexString(hex:String, Alpha:CGFloat) -> UIColor {
        
        let hexString:String = hex.trimmingCharacters(in:CharacterSet.whitespacesAndNewlines).uppercased()
        let redString:String = hexString.substring(with: NSRange(location: 0, length: 2))
        let greenString:String = (hexString as NSString).substring(with: NSRange(location: 2, length: 2))
        let blueString:String = (hexString as NSString).substring(with: NSRange(location: 4, length: 2))
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(
            red: CGFloat(Float(r) / 255.0),
            green: CGFloat(Float(g) / 255.0),
            blue: CGFloat(Float(b) / 255.0),
            alpha: CGFloat( Alpha )
        )
    }
}

