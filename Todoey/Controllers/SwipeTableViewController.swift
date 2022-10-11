//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by 白髪馨 on 2022/10/11.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 80.0
        
    }
    
    // TableView Datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        
        // delegateをSwipeTableViewControllerに設定し各delegateMethodを動作できるようにする
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        // スワイプの方向 右から左
        guard orientation == .right else { return nil }
        
        // 削除を実行した時の処理
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            // データモデル更新メソッドの実行
            self.updateModel(at: indexPath)
            

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
    
    func updateModel(at indexPath: IndexPath) {
        // データモデルを更新する
    }

}
