//
//  PlayListVC.swift
//  ProjectProtoType2
//
//  Created by Maninder Singh Jheeta on 4/22/17.
//  Copyright © 2017 Maninder Singh Jheeta All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion
import AVKit




var songs:[String] = []
var videos:[String] = []

var DirectoryName = ""

class PlayListVC: UIViewController, UITableViewDelegate,UITableViewDataSource  {

    @IBOutlet weak var tableView : UITableView!
    
    var audioStuffed = false
    var audioPlayer : AVAudioPlayer!
    var currentSong = 0
    let avPlayerViewController = AVPlayerViewController()
    var avPlayer:AVPlayer?
    
    @IBAction func changeMusicMode(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            PlayListVC.flag = true
            audioPlayer.play()
            tableView.reloadData()
        case 1:
            PlayListVC.flag = false
            audioPlayer.pause()
            tableView.reloadData()
        default:
            break
        }
    }
    /******************************************************************************/
    // these variables are used for the configuration of shake gestures.
    // tweaking the values for tresholdFirst move and tresholdBackMove will effect
    // the sensitivity of the shake.
    var startedLeftTilt = false
    var startedRightTilt = false
    var dateLastShake = NSDate(timeIntervalSinceNow: -2)
    var dateStartedTilt = NSDate(timeIntervalSinceNow: -2)
    var motionManager = CMMotionManager()
    let tresholdFirstMove = 3.0
    let tresholdBackMove = 0.5
    /******************************************************************************/
    

    
    
    //flag to test where to play video or audio
    static var flag = true
   // var songs=[String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isToolbarHidden = true
        
        let leftButton = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(self.back))
        leftButton.image = #imageLiteral(resourceName: "camera.png")
        navigationItem.leftBarButtonItem = leftButton
        //for shake gesture
        motionManager.gyroUpdateInterval = 0.01
        //end here
        
        do{
            //audioPlayer = nil
            let song = "\(DirectoryName)/\(songs[0])"
            print(song)
            let audioPath = Bundle.main.path(forResource: song, ofType: "mp3")
            print(audioPath!)
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            audioPlayer.play()
            currentSong = 0
            audioStuffed = true
        }
            
        catch{
            print("Error")
            
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func back() {
        //audioPlayer.stop()
        audioPlayer = nil
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    /******************************************************************************/
    //viewDidAppear contain code for some configuration for shake gesture.
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        motionManager.startGyroUpdates(to: OperationQueue.current!, withHandler: { (gyroData, error) -> Void in
            self.handleGyroData(rotation: (gyroData?.rotationRate)!)
        })
        
        
    }
    //viewDidAppera ends here
    /******************************************************************************/
    /******************************************************************************/
    //shake gesture's handler function.
    private func handleGyroData(rotation: CMRotationRate) {
        
        if fabs(rotation.z) > tresholdFirstMove && fabs(dateLastShake.timeIntervalSinceNow) > 0.3
        {
            if !startedRightTilt && !startedLeftTilt
            {
                dateStartedTilt = NSDate()
                if (rotation.z > 0)
                {
                    startedLeftTilt = true
                    startedRightTilt = false
                }
                else
                {
                    startedRightTilt = true
                    startedLeftTilt = false
                }
            }
        }
        
        if fabs(dateStartedTilt.timeIntervalSinceNow) >= 0.3
        {
            startedRightTilt = false
            startedLeftTilt = false
        }
        else
        {
            if (fabs(rotation.z) > tresholdBackMove)
            {
                if startedLeftTilt && rotation.z < 0
                {
                    print(PlayListVC.flag)
                    if PlayListVC.flag
                    {
                        prev()
                    }
                    else{
                        prevVid()
                    
                    }
                    
                    print("\\\n Shaked left\n/")
                }
                else if startedRightTilt && rotation.z > 0
                {
                    print(PlayListVC.flag)
                    dateLastShake = NSDate()
                    startedRightTilt = false
                    startedLeftTilt = false
                    if PlayListVC.flag{
                        next()
                    }
                    else{
                        nextVid()
                    }
                    print("\\\n Shaked right\n/")
                }
            }
        }
        
    }
    //Ends here.
    /******************************************************************************/
    

    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBAction func play(_ sender: Any) {
        if audioPlayer != nil{
            if PlayListVC.flag {
        if audioStuffed == true && audioPlayer.isPlaying == false{
            audioPlayer.play()
        }
        else {
            audioStuffed = true
            playThis(thisOne:songs[0])
        }
            }
    }
    }

    @IBAction func pause(_ sender: Any) {
        print(audioPlayer.isPlaying)
        if audioPlayer != nil{
            if PlayListVC.flag{
            if audioStuffed == true && audioPlayer.isPlaying == true
            {
                audioPlayer.pause()
            }
        }
        }
    }
    
    func nextVid(){
        
        
    }
    func prevVid()
    {}
    func next() {
        if currentSong < songs.count-1
        {
            playThis(thisOne:songs[currentSong+1])
            currentSong = currentSong+1
        }
        else{
            playThis(thisOne:songs[currentSong])
        }
    }
    
   func prev() {
        
        if currentSong == 0
        {
            playThis(thisOne:songs[currentSong])
        }
        else{
            playThis(thisOne:songs[currentSong-1])
            currentSong = currentSong-1
            
        }
    }
    
    
    @IBAction func slider(_ sender: UISlider) {
        audioPlayer.volume = sender.value
    }
    
    func playThis(thisOne:String)
    {
        do{
            let song = "\(DirectoryName)/\(thisOne)"
            let audioPath = Bundle.main.path(forResource: song, ofType: "mp3")
            audioPlayer = nil
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            audioPlayer.play()
        }
        catch{
            print("Error")
        }
        
    }

   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //navigationController?.isToolbarHidden = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if PlayListVC.flag{
            return songs.count
        }
        else
        {
            return videos.count
        }
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "PlayList")
        let cell = UITableViewCell()
        cell.textLabel?.font = UIFont(name: "Futura-Medium", size: 22)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        if PlayListVC.flag{
            let soundFilePath  = Bundle.main.path(forResource :"music1", ofType: "jpg" )
            cell.imageView?.image = UIImage(contentsOfFile: soundFilePath!)
            cell.textLabel?.text = songs[indexPath.row]
        }
        else{
            
            let viedoFilePath  = Bundle.main.path(forResource : videos[indexPath.row], ofType: "png" )
             cell.imageView?.image = UIImage(contentsOfFile: viedoFilePath!)
            cell.textLabel?.text = videos[indexPath.row]
            PlayListVC.flag = false
        }
        // Configure the cell...

        return cell
    }
 
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(PlayListVC.flag)
        {
        do{
            //let song = songs[indexPath.row].trimmingCharacters(in: .whitespaces)
            let song = "\(DirectoryName)/\(songs[indexPath.row])"
            print(song)
            let audioPath = Bundle.main.path(forResource: song, ofType: "mp3")
            self.audioPlayer = nil
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            audioPlayer.play()
            currentSong = indexPath.row
            audioStuffed = true
        }
        catch{
            print("Error")
            
        }
        }
        else
        {
            do{
                //let song = songs[indexPath.row].trimmingCharacters(in: .whitespaces)
                let song = "\(DirectoryName)Vid/\(videos[indexPath.row])"
                print(song)
                let videoPath = Bundle.main.path(forResource: song, ofType: "mp4")
                //edited this one msj
                ///print(audioPath)
                //let videoURL = URL(string: videoPath!)
                let videoURL = URL(fileURLWithPath: videoPath!)
                print(videoURL)
                self.avPlayer = AVPlayer(url: videoURL)
                self.avPlayerViewController.player = self.avPlayer
                
                self.present(self.avPlayerViewController, animated: true) {
                    self.avPlayerViewController.player?.play()
                }
                
            }
          
        }
    }

   
}
