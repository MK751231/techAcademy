//
//  HomeViewController.swift
//  techAcademy
//
//  Created by 越川将人 on 2021/09/28.
//

import UIKit
import RealmSwift

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    // 投稿データを格納する配列
    var postArray: [PostData] = []

    // Firestoreのリスナー
    // var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        // カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        let taskArray = try! Realm().objects(Property.self).sorted(byKeyPath: "date", ascending: true)
        print(taskArray.count)
        for i in 1..<taskArray.count + 1 {
            print(i)
            let postData = PostData(
                id: String(taskArray[i-1].id),
                property: taskArray[i-1].property,
                url: taskArray[i-1].url,
                date: taskArray[i-1].date,
                text: taskArray[i-1].text)
            
            print(postData)
        }
                // TableViewの表示を更新する
                self.tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: viewWillDisappear")
        // listenerを削除して監視を停止する
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        print(postArray[indexPath.row])
        
        return cell
    }

}

