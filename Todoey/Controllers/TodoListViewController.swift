//
//  ViewController.swift
//  Todoey
//
//  Created by 白髪馨 on 2022/09/12.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var todoItems: Results<Item>?
    
    @IBOutlet weak var searchBar: UISearchBar!
    /*CategoryViewControllerにて行選択時に選択カテゴリーに関連するitemをロード
     selectedCategoryへ値がセットされると処理される
     viewdidloadでは値がセットされない状態でitemをロードする可能性がある*/
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.colorCode {
            
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else {
                fatalError("Navigation controller does not exist.")
            }
            
            if let bgColor = UIColor(hexString: colorHex) {
                navBar.backgroundColor = bgColor
                navBar.standardAppearance.backgroundColor = bgColor
                navBar.scrollEdgeAppearance?.backgroundColor = bgColor
                navBar.scrollEdgeAppearance?.largeTitleTextAttributes = [.foregroundColor: ContrastColorOf(bgColor, returnFlat: true)]
                navBar.standardAppearance.largeTitleTextAttributes = [.foregroundColor: ContrastColorOf(bgColor, returnFlat: true)]
                
                navBar.tintColor = ContrastColorOf(bgColor, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(bgColor, returnFlat: true)]
                searchBar.barTintColor = bgColor
                
            }
        }
    }
    
    //MARK - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    //MARK - Cell Create
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            if let color = UIColor(hexString: selectedCategory!.colorCode)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            // done チェックマークフラグによってaccessoryTypeを更新する
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }

        return cell
    }


    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        // todoItemsがnilでなければ選択したindexPathの項目を取得
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    // チェックされていなければtrue,そうでなければfalse
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
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
            
            // 選択されているカテゴリーのitemsへ追加する
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        // Itemのオブジェクトを作成
                        let newItem = Item()

                        // 追加するデータをセット
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
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
    
    //MARK - DBから読み込む
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()

    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("Error deleting Item, \(error)")
            }
        }
    }
    
}

//MARK: -  seachBarMethod ベースとなるViewControllerの拡張
extension TodoListViewController: UISearchBarDelegate {

    // 検索ボタン押下時の処理
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Categoryと紐づいたtodoItemsに対してクエリを実行、登録日時でソート
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        

    }

    // searchBar内のテキスト変更時の処理
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // searchBar内のテキストが0の場合
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

