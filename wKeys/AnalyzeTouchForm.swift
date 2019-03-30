//
//  AnalyzeTouchForm.swift
//  wKeys
//
//  Created by spoonik on 2018/08/19.
//  Copyright © 2018年 spoonikapps. All rights reserved.
//

import Foundation
import CoreGraphics

// マルチタッチの指の位置関係を判断して、ベース音とコード名に変換して返すstaticクラス
//
class AnalyzeTouchForm {
    // このクラスの外部への公開関数は基本的にこれだけ。タッチ位置を複数入れて、ベース音とコード名の文字列に変換して返す
    static func get_chord_pattern(points: [CGPoint], bassrect: CGRect) -> (String?, String?) {
        if points.count == 0 {
            return (nil, nil)
        }
        let (bass_point, chord_point) = separate_bass_and_chord(points: points, area_w: bassrect.origin.x + bassrect.size.width)
        let bass = get_bass_name(p: bass_point, rect: bassrect)
        let sabuns = get_sabuns(points: chord_point)
        let idx = convert_sabuns_to_chord_index(sabuns: sabuns)
        return (bass, chord_graffiti[idx])
    }


    // 以下は外部へは見せない ------
    static let chord_graffiti = ["10":"m7", "20":"7", "1010":"M7", "01":"m9", "1020":"M9", "11":"dim7", "21":"aug9", "2010":"7sus4", "-1-1":"m", "00":"M"]  // タッチLocationの関係を符号化したもの。指位置分析の基礎定義＝ここがキモ
    static let touch_circle_radius = ResourceManager.getTouchAreaRadius()  // タッチ位置の差分を取る基準。もっと相対的に判断できるようにしたい TODO


    // タッチ位置の配列を、まずX座標でソートして、その後隣同士の距離の差分をX/Yごとにとり二次元配列に変換して返す
    static func get_sabuns(points: [CGPoint]) -> [[CGFloat]] {
        var p = points
        p.sort(by: {$0.x < $1.x})
        var sabun: [[CGFloat]] = []
        if p.count > 1 {
            for i in 0..<p.count-1 {
                sabun.append([p[i].x-p[i+1].x, p[i].y-p[i+1].y])
            }
        }
        else if p.count == 1 {
            sabun.append([0.0]) // 1つしかタッチがない場合特別な値を決めうちで入れる
        }
        return sabun
    }

    // 座標の差分をchord_graffiti[]のインデックスに変換する。相対位置を正規化する、という考え方
    static func convert_sabuns_to_chord_index(sabuns: [[CGFloat]]) -> String {
        var ret:[[Int]] = []
        for sabun in sabuns {
            if sabun == [0.0] {
                ret.append([-1,-1])
                break
            }
            ret.append([abs(Int(sabun[0]/CGFloat(touch_circle_radius))), abs(Int(sabun[1]/CGFloat(touch_circle_radius)))])
        }

        var text = ""
        for r in ret {
            text = text + String(r[0]) + String(r[1])
        }
        return text
    }

    // タッチ位置をベース部分とコード部分に分離する。単純なエリア判定だけ
    static func separate_bass_and_chord(points: [CGPoint], area_w: CGFloat) -> (CGPoint?, [CGPoint]) {
        var bass_point: CGPoint? = nil
        var chord_points: [CGPoint] = []
        for p in points {
            if p.x < area_w {
                bass_point = p
            } else {
                chord_points.append(p)
            }
        }
        return (bass_point, chord_points)
    }

    // 入力された1位置をベース音に変換。キーボードImageViewの中での12分割された範囲位置の判定だけ
    static func get_bass_name(p: CGPoint?, rect: CGRect) -> String? {
        if p == nil {
            return nil
        }
        let root = ResourceManager.getRootNames()
        let y = p!.y - rect.origin.y
        let key_idx = max(0, Int(y / (rect.height/CGFloat(root.count))))
        if key_idx < root.count {
            return root[key_idx]
        } else {
            return nil
        }
    }
}
