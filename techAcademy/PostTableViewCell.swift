//
//  PostTableViewCell.swift
//  techAcademy
//
//  Created by 越川将人 on 2021/10/19.
//

import UIKit
import RealmSwift

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var propertyCodeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var resisterButton: UIButton!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    // PostDataの内容をセルに表示
    func setPostData(_ postData: PostData) {
        
        // let imageUrl = postData.url!
        let imageFileName = postData.url!
        let imageFullPath = self.fileInDocumentsDirectory(filename: imageFileName)
        print("DEBUG_PRINT: \(imageFullPath)")
        let img = loadImageFromPath(path: imageFullPath)
        self.imageView!.image = img
        // self.imageView!.image = getImageByUrl(url: imageUrl)
        // 画像の表示
        // 日時の表示
        self.dateLabel.text = ""
        if let date = postData.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            formatter.calendar = Calendar(identifier: .gregorian) // 西暦表示対応
            let dateString = formatter.string(from: date)
            self.dateLabel.text = dateString
        }

        // 文字認識の表示
        //print(postData.text!)
        self.textView!.text = postData.text
    }
    
    // DocumentディレクトリのfileURLを取得
    func getDocumentsURL() -> NSURL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
        return documentsURL
    }

    // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
    func fileInDocumentsDirectory(filename: String) -> String {
        let fileURL = getDocumentsURL().appendingPathComponent(filename)
        return fileURL!.path
    }
    
    func loadImageFromPath(path: String) -> UIImage? {
        let image = UIImage(contentsOfFile: path)
        if image == nil {
            print("missing image at: \(path)")
        }
        return image
    }
}
