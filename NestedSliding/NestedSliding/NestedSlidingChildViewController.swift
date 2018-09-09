//
//  NestedSlidingChildViewController.swift
//  NestedSliding
//
//  Created by wangcong on 2018/9/8.
//  Copyright © 2018年 wangcong. All rights reserved.
//

import UIKit
import MJRefresh

class NestedSlidingChildViewController: UITableViewController {
    
    var numberOfRowInSection = 10

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.separatorStyle = .none
        tableView.register(UINib.init(nibName: "NestedSlidingTableViewCell", bundle: nil), forCellReuseIdentifier: "identifier")
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            
        })
        tableView.mj_footer.endRefreshingWithNoMoreData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension NestedSlidingChildViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowInSection
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "identifier", for: indexPath) as? NestedSlidingTableViewCell else {
            return UITableViewCell()
        }
        cell.label.text = "第 \(indexPath.row) 行"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension NestedSlidingChildViewController {
    
}
