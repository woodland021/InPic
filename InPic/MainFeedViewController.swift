//
//  MainFeedTableViewController.swift
//  InPic
//
//  Created by Jerry on 2/4/16.
//  Copyright © 2016 Ethan Thomas. All rights reserved.
//

import UIKit
import Firebase
import ImagePicker

class MainFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ImagePickerDelegate {

    var postArray = [Post]()
    let imagePickerController = ImagePickerController()
    var user:User?
    let image = Photo()
    var returnedImage = UIImage()
    var returnedString = ""

    var didLoadImages: Bool!

    let loggedInUser = NSUserDefaults.standardUserDefaults()

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        DataService.dataService.PHOTO_REF.keepSynced(true)
        self.tableView.rowHeight = 360
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func loadData()
    {
        DataService.dataService.POST_REF.queryOrderedByChild("timestamp").observeEventType(.ChildAdded, withBlock: { data in
//            print("Data: \(data.value)")
            let dataV = data.value as []
            for fdn: FDataSnapshot in data.value as! NSArray
            {
                print("Data: \(fdn)")
            }
        })
    }

    func sortByTimestamp()
    {
        self.postArray.sortInPlace({$0.timestamp > $1.timestamp})
    }

    override func viewDidAppear(animated: Bool) {
        if self.loggedInUser.stringForKey("uid") == nil {
            self.performSegueWithIdentifier("goLogInSegue", sender: nil)
        } else {
            self.loadData()
            self.tableView.reloadData()
        }
        print(self.loggedInUser.stringForKey("uid"))
    }

    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections

        return self.postArray.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MainFeedCell", forIndexPath: indexPath) as! MainFeedTableViewCell

        // Configure the cell...
        if (didLoadImages == true)
        {
            if let photoFoud = self.postArray[indexPath.section].photo {
                cell.cellImageView.image = photoFoud.image
            } else {
                cell.cellImageView.image = UIImage(named: "image")
            }
        } else {

        }

        return cell
    }

    @IBAction func onUploadButtonPressed(sender: UIBarButtonItem) {
        self.imagePickerController.delegate = self
        self.imagePickerController.imageLimit = 1
        presentViewController(self.imagePickerController, animated: true, completion: nil)
    }


    func wrapperDidPress(images: [UIImage]) {

    }

    func doneButtonDidPress(images: [UIImage]) {
        self.imagePickerController.dismissViewControllerAnimated(true) { () -> Void in
            if images.count > 0 {
                self.performSegueWithIdentifier("postImageSegue", sender: images[0])

            }
        }
    }

    @IBAction func unwindToMainFeed (sender: UIStoryboardSegue) {

    }

    func cancelButtonDidPress() {

    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.95)

        // Add a UILabel for the username here
        let label = UILabel(frame: CGRect(x:0, y:0, width: self.view.frame.width, height: 30))
        label.font.fontWithSize(CGFloat(8))
        label.textAlignment = .Center
        //        label.text = self.postArray[section].caption
        headerView.addSubview(label)

        return headerView

    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "postImageSegue" {
            let destination = segue.destinationViewController as! PostImageViewController
            destination.postImage = sender as? UIImage
        } else {
            if segue.identifier == "commentSegue" || segue.identifier == "likeSegue" {
                if let buttonPoint = sender!.center {
                    if let indexPath = self.tableView.indexPathForRowAtPoint(buttonPoint) {
                        let post = self.postArray[indexPath.section]
                        if segue.identifier == "commentSegue" {
                            let commentsVC = segue.destinationViewController as! CommentsViewController
                            commentsVC.post = post
                        } else if segue.identifier == "likeSegue" {
                            let likesVC = segue.destinationViewController as! CommentsViewController
                            likesVC.post = post
                        }
                    }

                }
            }

        }
    }
}
