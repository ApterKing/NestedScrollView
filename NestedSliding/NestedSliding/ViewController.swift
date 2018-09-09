//
//  ViewController.swift
//  NestedSliding
//
//  Created by wangcong on 2018/9/7.
//  Copyright © 2018年 wangcong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "identifier")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "identifier", for: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "单个tab数据未填充满屏幕"
        case 1:
            cell.textLabel?.text = "单个tab数据填充满屏幕，未填充满外层ScrollView contentSize"
        case 2:
            cell.textLabel?.text = "单个tab填充满"
        case 3:
            cell.textLabel?.text = "多个tab部分数据填充屏幕，部分未填充"
        case 4:
            cell.textLabel?.text = "上述情况外的其他多个tab情况"
        default:
            cell.textLabel?.text = "其他包含顶部horizontal滑动情况"
        }
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        cell.textLabel?.textColor = UIColor.darkText
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = NestedSlidingViewController()
        switch indexPath.row {
        case 0:
            vc.type = .singleTabNotFillScreen
        case 1:
            vc.type = .singleTabFillScreenNotFillContentSize
        case 2:
            vc.type = .single
        case 3:
            vc.type = .multiTabPartFill
        case 4:
            vc.type = .multiTab
        default:
            vc.type = .multiTabOtherHeaderView
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

