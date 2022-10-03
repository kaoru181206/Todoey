//
//  CategoryViewController.swift
//  Todoey
//
//  Created by 白髪馨 on 2022/09/27.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var categoryArray = [Category]()
    
    // 独自のplistファイルの作成
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
        
    }
    
    // MARK - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    // MARK - CategoryCell Create
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categoryArray[indexPath.row].name
        
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
            destinationVC.selectedCategory = categoryArray[indexPath.row]
            

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
            self.categoryArray.append(newCategory)
            
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
        
//        do {
//            categoryArray = try context.fetch(request)
//        } catch {
//            print("Error fetching data from context \(error)")
//        }
//
//        self.tableView.reloadData()
    }
    
    
}
