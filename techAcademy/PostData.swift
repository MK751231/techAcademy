//
//  PostData.swift
//  techAcademy
//
//  Created by 越川将人 on 2021/10/19.
//

import UIKit
import RealmSwift

class PostData: NSObject {
    var id: String
    var property: String?
    var url: String?
    var date: Date?
    var text: String?

    init(id: String, property: String?, url: String?, date: Date?, text: String? ) {
        self.id = id
        self.property = property
        self.url = url
        self.date = date
        self.text = text    }
    
}
