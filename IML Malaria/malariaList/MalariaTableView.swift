//
//  MalariaTableView.swift
//  IML Malaria
//
//  Created by Qazi Ammar Arshad on 10/04/2020.
//  Copyright © 2020 Neberox Technologies. All rights reserved.
//

import UIKit

class MalariaTableView: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MalariaTableView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MalariaTableViewCell
        cell.malariaImageView.image = UIImage(named: String(indexPath.row + 1))
        return cell
    }
    
    
}
