//
//  CategoryViewController.swift
//  Todoey
//
//  Created by 白髪馨 on 2022/09/27.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var categoryArray: Results<Category>?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
        
        tableView.rowHeight = 80.0
        
    }
    
    // MARK - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // categoryArray.countがnilでなければカテゴリー数を返す
        return categoryArray?.count ?? 1
    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SwipeTableViewCell
//        cell.delegate = self
//        return cell
//    }
    
    // MARK - CategoryCell Create
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categories Added yet"
        
        cell.delegate = self
        
        return cell
        
    }
    
    // MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    // Segue実行前処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // 遷移先ViewControllerの取得
        let destinationVC = segue.destination as! TodoListViewController
        
        // 選択されている行を識別する変数
        if let indexPath = tableView.indexPathForSelectedRow {
            // 値のセット
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
            

        }
    }
    

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
     
        // アラート内へ表示するtextFieldの作成
        var textField = UITextField()
        
        let alert = UIAlertController(title: "新しいカテゴリーの追加", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "追加", style: .default) { action in
            
            // Categoryのオブジェクトを作成
            let newCategory = Category()
            
            // 追加するデータをセット
            newCategory.name = textField.text!
            
            // DB登録メソッドの呼び出し
            self.save(category: newCategory)
            
        }
        
        // アラートへTextFieldの追加
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "新しいカテゴリー"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK - DB登録する
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    // MARK - DBから読み込む
    func loadCategories() {
        
        categoryArray = realm.objects(Category.self)
        
        tableView.reloadData()
    }

}

//MARK: - Swipe Cell Delegate  Method

extension CategoryViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        // スワイプの方向 右から左
        guard orientation == .right else { return nil }
        
        // スワイプ時の処理
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            if let categoryForDeletion = self.categoryArray?[indexPath.row] {
                do {
                    try self.realm.write {
                        self.realm.delete(categoryForDeletion)
                    }
                } catch {
                    print("Error deleting category, \(error)")
                }
                
                
            }
        }

        // スワイプ時に表示する画像を設定
        deleteAction.image = UIImage(systemName: "trash.fill")

        return [deleteAction]
    }
    
    // スワイプ動作のカスタマイズ
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
}
