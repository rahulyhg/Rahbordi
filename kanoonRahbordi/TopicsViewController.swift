//
//  TopicsViewController.swift
//  kanoonRahbordi
//
//  Created by negar on 96/Tir/21 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class TopicInfo {
    public var SumSbjId = Int()
    public var SbjName = String()
    public var OrderId = Int()
    public var SumSbjIdForQuiz = Int()
}

class TopicCell: UITableViewCell {
    
    @IBOutlet weak var cellLbl: UILabel!
    @IBOutlet weak var cellImg: UIImageView!
}

class TopicsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var topicsTable: UITableView!
    
    var groupCode : Int = 0
    var sumCrsID : Int = 0
    var sumCrsIDQ : Int = 0
    var topicsArr = [TopicInfo]()
    var indexpath = Int()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topicsTable.separatorStyle = .none
        
//        topicsTable.dataSource = self
//        topicsTable.delegate = self
        
        downloadTags(GCode: groupCode, SCID: sumCrsID){
            topicInfo,  error in
            if topicInfo != nil {
                self.topicsArr.append(topicInfo!)
                self.topicsTable.reloadData()
            }
        }
        
        
        //topicsTable.reloadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadTags(GCode : Int?, SCID : Int ,completionHandler: @escaping (TopicInfo?, Error?) -> ()) {
        if let  IDs: Int = GCode{
            
            Alamofire.request("http://www.kanoon.ir/Amoozesh/api/Document/GetSumSbjNbA?groupCode=\(IDs)&sumcrsid=\(SCID)")
                .responseJSON { response in
                    switch response.result {
                        case .success(let value):
                            let json = JSON(value)
                            if let jArray = json.array{
                                for topic in jArray{
                                    if topic["SumSbjId"] != 0 {
                                        let SumSbjId = topic["SumSbjId"].int
                                        let SbjName = topic["SbjName"].string
                                        let OrderId = topic["OrderId"].int
                                        let SumSbjIdForQuiz = topic["SumSbjIdForQuiz"].int
                                        let topicInfo = TopicInfo()
                                        topicInfo.SumSbjId = SumSbjId!
                                        topicInfo.SbjName = SbjName!
                                        topicInfo.OrderId = OrderId!
                                        topicInfo.SumSbjIdForQuiz = SumSbjIdForQuiz!
                                        completionHandler(topicInfo, nil)
                                    }
                                    
                                }
                            }
                        case .failure(let error):
                            completionHandler(nil, error)
                    }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topicsArr.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "topicCell", for: indexPath) as! TopicCell
        
        cell.cellLbl.text=topicsArr[indexPath.row].SbjName
        cell.cellImg.image = #imageLiteral(resourceName: "topicCursor")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexpath = indexPath.row
        performSegue(withIdentifier: "toTabs", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTabs"{
            let tabView = segue.destination as! UITabBarController
            let videoPage = tabView.viewControllers?[0] as! EducationalVideos
            videoPage.sumcrsid = sumCrsID
            videoPage.sumsbjid = topicsArr[indexpath].SumSbjId
            videoPage.groupCode = groupCode
            let summaryPage = tabView.viewControllers?[2] as! EducationalSummaries
            summaryPage.sumcrsid = sumCrsID
            summaryPage.sumsbjid = topicsArr[indexpath].SumSbjId
            summaryPage.subName = topicsArr[indexpath].SbjName
            summaryPage.groupCode = groupCode
            videoPage.subName = topicsArr[indexpath].SbjName
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
