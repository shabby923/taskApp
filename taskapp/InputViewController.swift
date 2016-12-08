//
//  inputViewController.swift
//  taskapp
//
//  Created by 櫻井 敬紹 on 2016/12/01.
//  Copyright © 2016年 shabby923. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications


class InputViewController: UIViewController {
    
    @IBOutlet weak var titleTextFIeld: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryTextField: UITextField!

    
    
    var task: Task!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextFIeld.text = task.title
        contentTextView.text = task.contents
        datePicker.date = task.date as Date
        categoryTextField.text = task.category
    }
    
    func dismissKeyboard(){
        //キーボードを閉じる
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextFIeld.text!
            self.task.contents = self.contentTextView.text
            self.task.date = self.datePicker.date as NSDate
            self.realm.add(self.task, update: true)
            self.task.category = self.categoryTextField.text!
        }
        
        setNotification(task: task)        
        super.viewWillDisappear(animated)
    }
    
    //タスクのローカル通知を登録する
    func setNotification(task: Task) {
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = task.title
            content.body = task.contents        //bodyが空だと音しかでない
            content.sound = UNNotificationSound.default()
            
            //ローカル通知が発動するtrigger(日付マッチ)を作成
            let calendar = NSCalendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date as Date)
            let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)

            //identifier, content, triggerからローカル通知を作成(edentifierが同じだとローカル通知を上書き保存)
            let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
            
            //ローカル通知を登録
            let center = UNUserNotificationCenter.current()
            center.add(request) { (error) in
                print(error ?? "ERROR")
            }
            
            //未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/-------------")
                    print(request)
                    print("/-------------")
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
