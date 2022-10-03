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
    
    /*CategoryViewControllerにて行選択時に選択カテゴリーに関連するitemをロード
     selectedCategoryへ値がセットされると処理される
     viewdidloadでは値がセットされない状態でitemをロードする可能性がある*/
    var selectedCategory : Category? {
        didSet {
//            loadItems()
        }
    }
    
    // 独自のplistファイルの作成
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
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
        
        // アラート内追加ボタンを押下時の処理
        let action = UIAlertAction(title: "追加", style: .default) { action in
            
//            let newItem = Item(context: self.context)
//
//            // 追加するデータをセット
//            newItem.title = textField.text!
//            newItem.done = false
//            newItem.parentCategory = self.selectedCategory
//            self.itemArray.append(newItem)
            
            // DB登録メソッドの呼び出し
            self.saveItems()
            
            self.tableView.reloadData()
   
        }
        
        // アラートへTextFieldを追加する
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "新しいアイテム"
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK - DB登録する
    func saveItems() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    //MARK - DBから読み込む
//    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
//
//        // CategoryTableのnameとselectedCategoryが一致するデータを取得するクエリ
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
//
//        // predicateがnilでない(searchBar条件あり)
//        if let addtionalPredicate = predicate {
//            /*CategoryTableのnameとselectedCategoryが一致するデータの中からsearchBar条件に一致するデータを取得する*/
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
//        } else {
//            // CategoryTableのnameとselectedCategoryが一致するデータを取得する
//            request.predicate = categoryPredicate
//        }
//
//        do {
//            itemArray = try context.fetch(request)
//        } catch {
//            print("Error fetching data from context \(error)")
//        }
//
//        tableView.reloadData()
//
//    }
    
}

//MARK: -  seachBarMethod ベースとなるViewControllerの拡張
//extension TodoListViewController: UISearchBarDelegate {
//
//    // 検索ボタン押下時の処理
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//
//        // 問い合わせクエリ
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        // title項目をアルファベット昇順にソート
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        // requestにセットした内容で取得してくる
//        loadItems(with: request, predicate: predicate)
//
//    }
//
//    // searchBar内のテキスト変更時の処理
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        // searchBar内のテキストが0の場合
//        if searchBar.text?.count == 0 {
//            loadItems()
//
//            DispatchQueue.main.async {
//                searchBar.resignFirstResponder()
//            }
//        }
//    }
//}

