# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* **Deployment instructions**
 1. Install the **eb-cli**
   Follow [these](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install.html) pretty straight forward instructions.

 2. Request an access key from the aws admin.
	 Details on how to get a key can be found [here](http://docs.aws.amazon.com/general/latest/gr/getting-aws-sec-creds.html).

 3. Configure the **eb cli**
    - Run **eb init**;
    - Select a default region ;
    - Provide your access key and secret key (the one you got on step 2);
    - Select an application to use: "**dantos**";
    - Select a platform: "**Ruby**";
    - Choose 'yes' to setup SSH access;
    - Choose an existing key pair.
    Detailed directions regarding configuration can be found [here](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-configuration.html).

 4. The deployment
    
    **Note**: *The eb client will use your working directory for the deployment, but only committed (not necessarily pushed) changes will be deployed*.
    
    The only command necessary for deployment is **eb deploy**. When you run this command, it will zip the contents of the project, upload it to aws and deploy automatically. You'll know if the deployment was successful if you see an output similar to this one:  
    ```
    dantos(master) $ eb deploy
    Creating application version archive "app-7ad1-160914_140654".
    Uploading dantos/app-7ad1-160914_140654.zip to S3. This may take a while.
    Upload Complete.
    INFO: Environment update is starting. 
    INFO: Deploying new version to instance(s).
    INFO: Environment health has transitioned from Ok to Info. 100.0 % of the requests are erroring with HTTP 4xx. Insufficient request rate (6.0 requests/min) to determine application health. Application update in progress on 1 instance. 0 out of 1 instance completed (running for 6 seconds).
    INFO: New application version was deployed to running EC2 instances.
    INFO: Environment update completed successfully.
    ```
    After the deployment, you can see that a new version has been created in the [dashboard](https://us-west-2.console.aws.amazon.com/elasticbeanstalk/home?region=us-west-2#/application/versions?applicationName=dantos). These versions can be redeployed just by selecting it in the versions list and hitting the "**deploy**" button.
   
    Another way to deploy the application is to zip the contents of the project and manually upload it to the aws dashboard [here](https://us-west-2.console.aws.amazon.com/elasticbeanstalk/home?region=us-west-2#/environment/dashboard?applicationName=dantos&environmentId=e-gxbz3wkymp), just by hitting the "**upload and deploy**" button.

    5. DB Migration
        rake db:create
        rake db:migrate
        rake db:seed
