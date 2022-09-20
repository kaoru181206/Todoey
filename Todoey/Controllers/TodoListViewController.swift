//
//  ViewController.swift
//  Todoey
//
//  Created by 白髪馨 on 2022/09/12.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    // 独自のplistファイルの作成
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        loadItems()
        
    }
    
    //MARK - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //MARK - Cell Create
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = itemArray[indexPath.row].title
        
        // done チェックマークフラグによってaccessoryTypeを更新する
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }


    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        // チェックされていなければtrue,そうでなければfalse
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        // 作成したplistファイルへエンコードしたitemArrayを書き込むメソッドを呼び出す
        self.saveItems()
        
        // cellが選択された場合、画面をリロードする
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "新規追加", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "追加", style: .default) { action in
            // 追加ボタンを押下時の処理

            let newItem = Item(context: self.context)
            
            // 追加するデータをセット
            newItem.title = textField.text!
            newItem.done = false
            self.itemArray.append(newItem)
            
            // 作成したplistファイルへエンコードしたitemArrayを書き込むメソッドを呼び出す
            self.saveItems()
            
            self.tableView.reloadData()
   
        }
        
        // アラートへTextFieldを追加する
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "新しいアイテム"
            textField = alertTextField
            //print(textField.text)
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK - 作成したplistファイルへエンコードしたitemArrayを書き込むメソッド
    func saveItems() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    //MARK - plistファイルへ保持しているデータを読み込む
//    func loadItems() {
//        if let data = try? Data(contentsOf: dataFilePath!) {
//            let decoder = PropertyListDecoder()
//            do {
//                itemArray = try decoder.decode([Item].self, from: data)
//            } catch {
//                print("Error decoding item array, \(error)")
//            }
//        }
//    }
}

