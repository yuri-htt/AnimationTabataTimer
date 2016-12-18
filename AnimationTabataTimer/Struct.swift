//
//  Struct.swift
//  AnimationTabataTimer
//
//  Created by 田山　由理 on 2016/12/16.
//  Copyright © 2016年 Yuri Tayama. All rights reserved.
//

import UIKit

struct Duration {
    //
    let TimerUpdateDuration:CGFloat = 1.0
    let prepareAnimDuration:CGFloat = 1.0
    let startTitleDuration :CGFloat = 1.0
}

struct Scale {
    let comeFront:CGFloat = 1.0
    let goBack:CGFloat = 0.5
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

struct TitleText {
    var title = "TABATA TIMER"
    var ready = "READY"
}

struct DisplayString {
    var unit = "Sec"
}

struct Color {
    var fontColor = Formatter().colorWithHexString(hex: "FFFFFF", Alpha: 1.0 )
    let yellow:UIColor = Formatter().colorWithHexString(hex: "B9AD1E", Alpha: 1.0)
    let red:UIColor = Formatter().colorWithHexString(hex: "CC2D62", Alpha: 1.0)
    let blue:UIColor = Formatter().colorWithHexString(hex: "2D8CDD", Alpha: 1.0)
    let green:UIColor = Formatter().colorWithHexString(hex: "70BF41", Alpha: 1.0)
    let orange:UIColor = Formatter().colorWithHexString(hex: "F39019", Alpha: 1.0)
}

struct Formatter {
    //hex:16進数
    func colorWithHexString (hex:String, Alpha:CGFloat) -> UIColor {
        
        //削除する文字の集合(空白と改行)を指定し、大文字に
        let hexString:String = hex.trimmingCharacters(in:CharacterSet.whitespacesAndNewlines).uppercased()
        
        let redString:String = (hexString as NSString).substring(with: NSRange(location: 0, length: 2))
        let greenString:String = (hexString as NSString).substring(with: NSRange(location: 2, length: 2))
        let blueString:String = (hexString as NSString).substring(with: NSRange(location: 4, length: 2))
        
        var red:CUnsignedInt = 0, green:CUnsignedInt = 0, blue:CUnsignedInt = 0
        //渡されたStringをスキャンして16進数に変換,変数
        //ここが参照渡しな理由がわからん
        Scanner(string: redString).scanHexInt32(&red)
        Scanner(string: greenString).scanHexInt32(&green)
        Scanner(string: blueString).scanHexInt32(&blue)
        
        return UIColor(
            red: CGFloat(Float(red) / 255.0),
            green: CGFloat(Float(green) / 255.0),
            blue: CGFloat(Float(blue) / 255.0),
            alpha: CGFloat( Alpha )
        )
    }
}
