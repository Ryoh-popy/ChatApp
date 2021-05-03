//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Ryoh on 2021/05/02.
//

import UIKit
import Firebase
import SDWebImage

class ChatViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    // ダッシュボードにアクセス
    let db = Firestore.firestore()
    
    var roomName = String()
    var imageString = String()
    
    // メッセージ構造体が入る配列
    var messages:[Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // カスタムセルの登録
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        if UserDefaults.standard.object(forKey: "userImage") != nil {
            
            imageString = UserDefaults.standard.object(forKey: "userImage") as! String
        }
        
        if roomName == ""{
            roomName = "All"
        }
        
        self.navigationItem.title = roomName
        
        // セルのロード
        loadMessages(roomName: roomName)
        // Do any additional setup after loading the view.
    }
    
    
    func loadMessages(roomName:String){
        // 日付順に取得
        db.collection(roomName).order(by: "date").addSnapshotListener{ (snapShot,error) in
            self.messages = []
            
            if error != nil{
                print(error.debugDescription)
                return
            }
            if let snapShotDoc = snapShot?.documents{
                
                for doc in snapShotDoc{
                    let date = doc.data()
                    if let sender = date["sender"] as? String,let
                        body = date["body"] as? String,let
                            imageString = date["imageString"] as? String{
                        
                        let newMessage = Message(sender: sender, body: body, imageString: imageString)
                        
                        self.messages.append(newMessage)
                        
                        DispatchQueue.main.async {
                            // リロードしてテーブルにメッセージを読み込む
                            self.tableView.reloadData()
                            
                            let indexPath = IndexPath(row:
                                                        self.messages.count - 1, section:0)
                            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                        }
                    }
                    
                }
            }
        }
    }
    
    // セルの数＝メッセージの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // セルの中身
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MessageCell
        
        let message = messages[indexPath.row]
        
        cell.label.text = message.body
        
        // 自分が送った場合と相手に送られた場合
        if message.sender == Auth.auth().currentUser?.email{
            
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.rightImageView.sd_setImage(with: URL(string: imageString),completed:nil)
            cell.leftImageView.sd_setImage(with: URL(string: messages[indexPath.row].imageString), completed: nil)
            
            cell.backView.backgroundColor = .systemTeal
            cell.label.textColor = .white
        
        }else{
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.rightImageView.sd_setImage(with: URL(string: imageString),completed:nil)
            cell.leftImageView.sd_setImage(with: URL(string: messages[indexPath.row].imageString), completed: nil)
            
            cell.backView.backgroundColor = .orange
            cell.label.textColor = .white
        }
        
        return cell
        
    }
    
    @IBAction func send(_ sender: Any) {
        if let messageBody = messageTextField.text,let sender = Auth.auth().currentUser?.email{
            
            db.collection(roomName).addDocument(data:["sender":sender,"body":messageBody,"imageString":imageString,"date":Date().timeIntervalSince1970]){ (error) in
                
                if error != nil{
                    // エラーをログに出す
                    print(error.debugDescription)
                    return
                }
                
                // 非同期処理
                DispatchQueue.main.async {
                    self.messageTextField.text = ""
                    //キーボード閉じる
                    self.messageTextField.resignFirstResponder()
                }
                
                
                
            }
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
