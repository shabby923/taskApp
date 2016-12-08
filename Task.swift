//
//  Task.swift
//  
//
//  Created by 櫻井 敬紹 on 2016/12/05.
//
//

import UIKit
import RealmSwift

class Task: Object {

    // 管理用 ID。プライマリーキー
    dynamic var id = 0
    
    // タイトル
    dynamic var title = ""
    
    // 内容
    dynamic var contents = ""
    
    /// 日時
    dynamic var date = NSDate()
    
    dynamic var category = ""
    
    /**
     id をプライマリーキーとして設定
     */

    override static func primaryKey() -> String? {
        return "id"
    
    }
    
}
