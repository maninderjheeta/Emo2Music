//
//  ViewController.swift
//  ProjectProtoType2
//
//  Created by Maninder Singh Jheeta on 4/18/17.
//  Copyright © 2017 Maninder Singh Jheeta All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import CoreMotion

class ViewController: UIViewController,AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    /******************************************************************************/
    // these variables are used for the configuration of shake gestures.
    // tweaking the values for tresholdFirst move and tresholdBackMove will effect 
    // the sensitivity of the shake.
   /* var startedLeftTilt = false
    var startedRightTilt = false
    var dateLastShake = NSDate(timeIntervalSinceNow: -2)
    var dateStartedTilt = NSDate(timeIntervalSinceNow: -2)
    var motionManager = CMMotionManager()
    let tresholdFirstMove = 3.0
    let tresholdBackMove = 0.5*/
    /******************************************************************************/
    
    // instruction flag
    var instruction_flag = true
    // Button to click photo
    @IBOutlet weak var smileButton: UIButton!

    // camera view to take image
    @IBOutlet weak var cameraView: UIView!
    
    // Image view to capture the still
    @IBOutlet weak var myImageView: UIImageView!
    
    @IBOutlet weak var button: UIButton!
    
    // this will hold the data to be send to the server. Basically it is the latest image
    // taken from the camera and saved to the photogallary.
    var imageData : Data?
    
    /******************************************************************************/
    // these variables are used for the camera and photo configurations.
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCapturePhotoOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var data : NSData?
    var previewPhotoSampleBuffer: CMSampleBuffer?
    var photoSampleBuffer: CMSampleBuffer?
    /******************************************************************************/
    
    
    required init?(coder aDecoder:NSCoder){
        super.init(coder:aDecoder)
        
    }

    
    /******************************************************************************/
    //take the camera into action again
    func retakePhoto()
    {
        myImageView.isHidden = true
        myImageView.image = nil
        smileButton.isHidden = false
    }
    //retakePhoto ends here
    /******************************************************************************/
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if instruction_flag{
        let instruction = "✔️ Press the button below to take a snap.\n✔️ While playing music shake left for previous song.\n✔️ Shape right for next song."
        let refreshAlert = UIAlertController(title: "Instruction", message: instruction, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle Ok logic here")
        }))
        instruction_flag = false
        self.present(refreshAlert, animated: true, completion: nil)
        }
        self.activityIndicator.isHidden = true

    }
    /******************************************************************************/
    //the function to send request to the server.
    
    func sendRequestToServer()
    {
        
        self.activityIndicator.startAnimating()
        fetchPhotos()
        print(self.imageData!)
        let methodname = "POST"
        let serverRequest = ServerRequest()
        let responseData = serverRequest.sendRequest(methodname,self.imageData!)
        print(responseData)
        
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        let person = Person()
        let success = person.getFeeling(responseData)
        let songObj :Songs = Songs()
        if success == true{
            DirectoryName = songObj.evaluateResponse(person.getHappinessCount(), person.getSadnessCount())
            print ("Get Some Response")
            if songs.count > 0{
                songs.removeAll()
            }
            if videos.count > 0{
                videos.removeAll()
            }
            for s in songObj.songs{
                songs.append(s)
            }
            for s in songObj.videos{
                videos.append(s)
            }
            retakePhoto()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let playListController = storyboard.instantiateViewController(withIdentifier: "PlayListVC")
            playListController.title =  songObj.directoryName+" Songs"
            let navVC = UINavigationController()
            navVC.pushViewController(playListController, animated: true)
            present(navVC, animated: true, completion: nil)
        }
        else{
            print("Noting has been returned from the server")
            retakePhoto()
            let instruction = "😇 You look terrific, seems our server was unable to process this. Please try again.☺️"
            let refreshAlert = UIAlertController(title: "Oops", message: instruction, preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle Ok logic here")
            }))
            instruction_flag = false
            self.present(refreshAlert, animated: true, completion: nil)
        }

}
    
    // sendRequestToServer ends here.
    /******************************************************************************/


    /******************************************************************************/
    //vieDidLoad contain some initialization code for swipe and shake gesture.
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isToolbarHidden = true
        //Removed the swiping gesture functionality for better user experience
        //for Swipe gesture
        /*
         let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
         */
        //end here
        
        
        self.view.insertSubview(myImageView, aboveSubview: cameraView)
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    //end of view Did load
    /******************************************************************************/
    
    
    
    //Eliminating this functionality for better user experience
    /******************************************************************************/
    //for swipe gesture
    /*func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                retakePhoto()
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.left:
                sendRequestToServer()
                print("Swiped left")
            default:
                break
            }
        }
    }
 */
    //End here
    /******************************************************************************/
    
  
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        

        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let deviceSession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInDualCamera,.builtInTelephotoCamera,.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified)
        for device in (deviceSession?.devices)! {
            if device.position == AVCaptureDevicePosition.front{
                do{
                    let input = try AVCaptureDeviceInput(device:device)
                    if captureSession.canAddInput(input)
                    {
                        captureSession.addInput(input)
                        if captureSession.canAddOutput(sessionOutput){
                            captureSession.addOutput(sessionOutput)
                            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                            previewLayer.connection.videoOrientation = .portrait
                            cameraView.layer.addSublayer(previewLayer)
                            cameraView.addSubview(button)
                            
                            previewLayer.position = CGPoint(x: self.cameraView.frame.width/2, y: self.cameraView.frame.height/2)
                            previewLayer.bounds = cameraView.frame
                            captureSession.startRunning()
                        }
                    }
                }
                catch let avError
                {
                    print(avError)
                }
            }
        }
        
    }

    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error{
            print(error.localizedDescription)
            return
        }
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = photoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer){
            self.photoSampleBuffer = photoSampleBuffer
            self.previewPhotoSampleBuffer = previewPhotoSampleBuffer
            data = dataImage as? NSData
            let takenImage :UIImage = UIImage(data:dataImage)!
            myImageView.isHidden = false
            self.activityIndicator.isHidden = false
            myImageView.image = takenImage
            smileButton.isHidden = true
        }
    }
    //Allow to call the method to save image to the photlibrary. 
    //It is called after the capturing of image is completed.
    func capture(_ captureOutput: AVCapturePhotoOutput,
                 didFinishCaptureForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings,
                 error: Error?) {
        guard error == nil else {
            print("Error in capture process: \(String(describing: error))")
            return
        }
        
        if let photoSampleBuffer = self.photoSampleBuffer {
            saveSampleBufferToPhotoLibrary(photoSampleBuffer,
                                           previewSampleBuffer: self.previewPhotoSampleBuffer,
                                           completionHandler: { success, error in
                                            if success {
                                                print("Added JPEG photo to library.")
                                                //self.retakePhoto()
                                                self.sendRequestToServer()
                                            } else {
                                                print("Error adding JPEG photo to library: \(String(describing: error))")
                                            }
            })
        }
    }
    
    //This function save the photo to the photolibrary.
    func saveSampleBufferToPhotoLibrary(_ sampleBuffer: CMSampleBuffer,
                                        previewSampleBuffer: CMSampleBuffer?,
                                        completionHandler: ((_ success: Bool, _ error: Error?) -> Void)?) {
        self.checkPhotoLibraryAuthorization({ authorized in
            guard authorized else {
                print("Permission to access photo library denied.")
                completionHandler?(false, nil)
                return
            }
            
            guard let jpegData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(
                forJPEGSampleBuffer: sampleBuffer,
                previewPhotoSampleBuffer: previewSampleBuffer)
                else {
                    print("Unable to create JPEG data.")
                    completionHandler?(false, nil)
                    return
            }
            
            PHPhotoLibrary.shared().performChanges( {
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: PHAssetResourceType.photo, data: jpegData, options: nil)
            }, completionHandler: { success, error in
                DispatchQueue.main.async {
                    completionHandler?(success, error)
                }
            })
        })
    }

    //Checking for the authorization
    func checkPhotoLibraryAuthorization(_ completionHandler: @escaping ((_ authorized: Bool) -> Void)) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            // The user has previously granted access to the photo library.
            completionHandler(true)
            
        case .notDetermined:
            // The user has not yet been presented with the option to grant photo library access so request access.
            PHPhotoLibrary.requestAuthorization({ status in
                completionHandler((status == .authorized))
            })
            
        case .denied:
            // The user has previously denied access.
            completionHandler(false)
            
        case .restricted:
            // The user doesn't have the authority to request access e.g. parental restriction.
            completionHandler(false)
        }
    }
   
    

    func takePhoto(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String:previewPixelType, kCVPixelBufferWidthKey as String: 160,kCVPixelBufferHeightKey as String: 160]
        settings.previewPhotoFormat = previewFormat
        sessionOutput.capturePhoto(with: settings, delegate: self)
        
    }
    
    
    
    
    @IBOutlet weak var tempImageView: UIImageView!
    func myImageUploadRequest()
    {
        
    }
    
    
    
    //Functionality to fetch data from the photo library
    
    var images:NSMutableArray! // <-- Array to hold the fetched images
    var totalImageCountNeeded:Int! // <-- The number of images to fetch
    
    func fetchPhotos () {
        images = NSMutableArray()
        totalImageCountNeeded = 1
        self.fetchPhotoAtIndexFromEnd(index: 0)
    }
    
    // Repeatedly call the following method while incrementing
    // the index until all the photos are fetched
    func fetchPhotoAtIndexFromEnd(index:Int) {
        
        let imgManager = PHImageManager.default()
        
        // Note that if the request is not set to synchronous
        // the requestImageForAsset will return both the image
        // and thumbnail; by setting synchronous to true it
        // will return just the thumbnail
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        // Sort the images by creation date
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
        
        if let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions) {
            
            // If the fetch result isn't empty,
            // proceed with the image request
            if fetchResult.count > 0 {
                // Perform the image request
                imgManager.requestImage(for: fetchResult.object(at: fetchResult.count - 1 - index) as PHAsset, targetSize: view.frame.size, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
                    
                    // Add the returned image to your array
                    self.images.add(image!)
                    if index + 1 < fetchResult.count && self.images.count < self.totalImageCountNeeded {
                        self.fetchPhotoAtIndexFromEnd(index: index + 1)
                    } else {
                        // Else you have completed creating your array
                        print("Completed array: \(self.images)")
                        self.imageData = UIImageJPEGRepresentation(self.images.object(at: 0) as! UIImage, 1)
                        print(self.imageData!)
                        
                    }
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

