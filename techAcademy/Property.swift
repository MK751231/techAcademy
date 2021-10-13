//
//  Property.swift
//  techAcademy
//
//  Created by 越川将人 on 2021/09/28.
//

import RealmSwift

class Property: Object {
    // 管理用ID。プライマリーキー
    @objc dynamic var id = 0
    
    // 物件名
    @objc dynamic var property = ""
    
    // 日時
    @objc dynamic var date = Date()

    // 画像URL
    @objc dynamic var url = ""
    
    //文字座標
    let imageRectPoints =  List<RectPoints>()
    
    // id をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // 配列用クラス
    class RectPoints: Object {
        @objc dynamic var points = ""
    }
}
