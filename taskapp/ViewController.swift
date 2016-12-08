//
//  ViewController.swift
//  taskapp
//
//  Created by 櫻井 敬紹 on 2016/12/01.
//  Copyright © 2016年 shabby923. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var testSearchBar: UISearchBar!
    
    
    //Realmインスタンスを取得する
    let realm = try! Realm()
    
    
    //DB内のタスクが格納されるリスト
    //日付近い順でソート：降順
    //以降内容をアップデートするとリスト内は自動的に更新される
    var taskArray = try! Realm().objects(Task.self).sorted(byProperty: "date", ascending: false)
    var showArray: Results<Task>?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        testSearchBar.delegate = self
        testSearchBar.enablesReturnKeyAutomatically = false
        
//        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:tableView, action:#selector(dismissKeyboard))
//        self.view.addGestureRecognizer(tapGesture)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController: InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }


    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        //cellに値を設定する
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date as Date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            //削除されたタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            //ローカル通知をキャンセルする
            if #available(iOS 10.0, *) {
                let center = UNUserNotificationCenter.current()
                center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
                
                //データベースから削除する
                try! realm.write {
                    self.realm.delete(task)
                    tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
                }
                
                center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                    for request in requests {
                        print("/---------------")
                        print(request)
                        print("---------------/")
                    }
                    
                }
            } else {
                // Fallback on earlier versions
            }
            
    }
}
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (searchText == "") {
            taskArray = try! Realm().objects(Task.self).sorted(byProperty: "date", ascending: false)
            
        }else{
            taskArray = try! Realm().objects(Task.self).filter("category contains '\(searchText)'")
        }
        tableView.reloadData()
        resignFirstResponder()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        taskArray = try! Realm().objects(Task.self).sorted(byProperty: "date", ascending: false)
        view.endEditing(true)
        tableView.reloadData()
        
    }
    
//    func dismissKeyboard(){
//        //キーボードを閉じる
//        view.endEditing(true)
//    }
    
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

}


