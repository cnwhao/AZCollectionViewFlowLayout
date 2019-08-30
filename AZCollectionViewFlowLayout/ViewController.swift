//
//  ViewController.swift
//  AZCollectionViewFlowLayout
//
//  Created by wanghaohao on 2019/8/26.
//  Copyright © 2019 whao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private lazy var tableview: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        
        table.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        return table
    }()
    
    private let tableData:Array<String> = ["横向等宽瀑布流", "纵向等宽瀑布流", "tag标签布局", "线性布局", "圆形布局"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.view.addSubview(tableview)
        var rect = self.view.bounds
        rect.origin.y = 100
        rect.size.height -= rect.origin.y
        tableview.frame = rect
    }
}

extension ViewController:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "UITableViewCell")
        cell?.textLabel?.text = tableData[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.navigationController?.pushViewController(AZFlowLayoutController(flowStyle: .horizontal), animated: true)
        } else if indexPath.row == 1 {
            self.navigationController?.pushViewController(AZFlowLayoutController(flowStyle: .vertical), animated: true)
        } else if indexPath.row == 2 {
            self.navigationController?.pushViewController(AZCollectionViewTagLayoutController(), animated: true)
        }
    }
}



