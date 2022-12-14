//
//  CategoryViewController.swift
//  Todoey
//
//  Created by 白髪馨 on 2022/09/27.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categoryArray: Results<Category>?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
        
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist.")
        }
        
        if let bgColor = UIColor(hexString: "1D9BF6") {
            navBar.standardAppearance.backgroundColor = bgColor
            navBar.backgroundColor = bgColor
            navBar.standardAppearance.backgroundColor = bgColor
            navBar.scrollEdgeAppearance?.backgroundColor = bgColor
            navBar.scrollEdgeAppearance?.largeTitleTextAttributes = [.foregroundColor: ContrastColorOf(bgColor, returnFlat: true)]
            navBar.standardAppearance.largeTitleTextAttributes = [.foregroundColor: ContrastColorOf(bgColor, returnFlat: true)]
        }
        
    }
    
    // MARK - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // categoryArray.countがnilでなければカテゴリー数を返す
        return categoryArray?.count ?? 1
    }
    
    // MARK - CategoryCell Create
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // superクラスで作成されたCellにアクセスしCellがsuperクラスからreturnされてくる
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categoryArray?[indexPath.row] {
            cell.textLabel?.text = category.name
            
            guard let categoryColor = UIColor(hexString: category.colorCode) else {fatalError()}
            
            cell.backgroundColor = categoryColor
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        }

        return cell
        
    }
    
    // MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
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
            newCategory.colorCode = UIColor.randomFlat().hexValue()
            
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
    
    // MARK: - Data Manipulation Methods
    
    // MARK - データ登録する
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
    
    // MARK - データ読み込み
    func loadCategories() {
        
        categoryArray = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    // MARK - データの削除 Swipe
    override func updateModel(at indexPath: IndexPath) {
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
    
    

}
