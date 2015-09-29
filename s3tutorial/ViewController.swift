//
//  ViewController.swift
//  s3tutorial
//
//  Created by Rob Kerr on 2/14/15.
//  Copyright (c) 2015 Mobile Toolworks, LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Hard-coded names for the tutorial bucket and the file uploaded at the beginning
        let s3BucketName = "com.mobiletoolworks.s3tutorial"
        let fileName = "MobileToolworks-Logo.jpg"

        let downloadFilePath = NSTemporaryDirectory().stringByAppendingPathComponent(fileName)
        let downloadingFileURL = NSURL.fileURLWithPath(downloadFilePath)

        // Set the logging to verbose so we can see in the debug console what is happening
        AWSLogger.defaultLogger().logLevel = .Verbose
        
        // Create a credential provider for AWS requests
        let credentialsProvider = AWSCognitoCredentialsProvider.credentialsWithRegionType(
            AWSRegionType.USEast1,
            accountId: "999999999999",  // <== Your AWS Account ID goes here (get it from the AWS account settings)
            identityPoolId: "us-east-1:ac328da6-63f3-4748-9b8f-25b564422968",  // <== get this from the Cognito sample code panel
            unauthRoleArn: "arn:aws:iam::696446148911:role/Cognito_s3tutorialUnauth_DefaultRole",  // <== Find this in the IAM console
            authRoleArn: "arn:aws:iam::696446148911:role/Cognito_s3tutorialAuth_DefaultRole")       // <== Find this in the IAM console
        
        // Create a service configuration for AWS requests
        let defaultServiceConfiguration = AWSServiceConfiguration(
            region: AWSRegionType.USEast1,
            credentialsProvider: credentialsProvider)
        
        // Set the default service manager to use in this Application
        AWSServiceManager.defaultServiceManager().setDefaultServiceConfiguration(defaultServiceConfiguration)

        // Create a new download request to S3, and set its properties
        let downloadRequest = AWSS3TransferManagerDownloadRequest()
            downloadRequest.bucket = s3BucketName
            downloadRequest.key  = fileName
            downloadRequest.downloadingFileURL = downloadingFileURL

        // Use the default S3 transfer manager for this request
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        // Start asynchronous download
        transferManager.download(downloadRequest).continueWithBlock { (task: BFTask!) -> AnyObject! in
            if task.error != nil {
                println("Error downloading")
                println(task.error.description)
            }
            else {
                println("Download complete")

                // Download is complete, set the UIImageView to show the file that was downloaded
                let image = UIImage(contentsOfFile: downloadFilePath)
                self.imageView.image = image
            }
            
            return nil
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

