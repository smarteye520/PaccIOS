//
//  SearchResultViewController.swift
//  PACC
//
//  Created by RSS on 7/13/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

class SearchResultViewController: BaseViewController {

    @IBOutlet weak var searchResultTable: UITableView!
    var fromMessageView : Bool = false
    var businesses: [User] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    func initView() {
        searchResultTable.allowsSelection = false
        searchResultTable.separatorStyle = .none
        searchResultTable.register(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: "searchCell")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionClose(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }      
    
}

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource, SearchCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as! SearchCell
        if cell.user == nil || cell.user != self.businesses[indexPath.row] {
            cell.user = self.businesses[indexPath.row]
            cell.delegate = self
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func gotoProfile(_ cell: SearchCell) {
        if fromMessageView == true {
            NotificationCenter.default.post(name: .addMessageUser, object: self, userInfo: ["addUserInfoKey": cell.user!])
            self.navigationController?.popViewController(animated: true)
        }else{
           let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileViewController
           vc.user = cell.user
           self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
