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
        
        // let imageUrl = postData.url
        // 画像の表示
        // self.showImage(imageView: imageView!, url: "{\(String(describing: imageUrl))}")
        
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
    
    private func showImage(imageView: UIImageView, url: String) {
            let imageUrl = URL(string: url)
            do {
                let data = try Data(contentsOf: imageUrl!)
                let image = UIImage(data: data)
                imageView.image = image
            } catch let err {
                print("Error: \(err.localizedDescription)")
            }
    }
}
