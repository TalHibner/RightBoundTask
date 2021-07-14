# RightBoundTask  
  
## Prerequierments  
### Procedure to download terraform :  
- Go to Terraform’s website and click on the download link for your operating system.  
- A zip file will get downloaded. After unzipping it, you will get a file named terraform.exe for windows. Copy this file.  
- Create a folder named bin in C:\Users\John\ and inside C:\Users\John\bin paste terraform.exe.  
- Go to control panel and open system properties. Then click on Environment variables and under User variable for John section, click on path and add a new path as - C:\Users\John\bin.  
- To confirm terraform is working or not, open Powershell and run terraform --version , it should display the version of terraform installed.  
   
### Creating an IAM user:  
- Go to Create IAM User (console) and create an IAM user with Administrator access permission. Ensure that this IAM user has console as well as programmatic access.  
- Download the CSV file.  
- Open Git bash CLI and navigate to C:\Users\John\ and create a folder named .aws. Then navigate to C:\Users\John\.aws\ and create a file named credentials using command touch credentials. Open this file in Vim editor using command vim credentials. Enter the following from the CSV file that you have downloaded and save it.  
[default]  
aws_access_key_id=******************  
aws_secret_access_key=*******************  
    
Now, everything is set and we are ready to begin working in our main project directory.  
  
### The AWS CLI installed locally: 
   https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html  
  
-----------------------------------------------------------------------------------------------  
  
## Provisioning and Deploying the lambda functions  
Now we’ll open the terminal and run 'terraform init'. It will download all the required plugins.  
Then, we’ll run 'terraform apply -auto-approve'. It will deploy all the resources into AWS cloud, which we can confirm by opening the AWS console in the browser.   
After running terraform apply -auto-approve command, there will be a URL present in the CLI which will look like the following —  
https://brqhu55tr8.execute-api.us-east-1.amazonaws.com/Prod  

-----------------------------------------------------------------------------------------------
## Limitations
Terraform currently supports only sqs, sms, lambda, application (fully) and http, https, email and email-json (partially).  
There is partially support for email and email-json protocols because the endpoint needs to be authorized and does not generate an ARN until the target email address has been validated. This breaks the Terraform model and as a result, is not currently supported.  
You cannot unsubscribe to a subscription that is pending confirmation. If you use email, email-json, or http/https (without auto-confirmation enabled), until the subscription is confirmed (e.g., outside of Terraform), AWS does not allow Terraform to delete / unsubscribe the subscription. If you destroy an unconfirmed subscription, Terraform will remove the subscription from its state but the subscription will still exist in AWS. However, if you delete an SNS topic, SNS deletes all the subscriptions associated with the topic. Also, you can import a subscription after confirmation and then have the capability to delete it.  
After running 'terraform apply' you will get an email to the email you subscrubed to:  
![Screenshot 2021-07-12 012239](https://user-images.githubusercontent.com/9087272/125478374-ae7f204f-5c0e-4dbb-a988-67bca14a5b79.jpg)  
  
After you clicked the "Confirm subscrition" you will get:  
![Screenshot 2021-07-12 012250](https://user-images.githubusercontent.com/9087272/125478584-b436b17f-1731-4ce8-bc32-c8cd0afe93ff.jpg) 
  
And then you are good to go! :-)



--------------------------------------------------------------------------------------------------

## Cleaning up
Now to destroy all the AWS resources that you created execute the following command:

'terraform destroy  -auto-approve'

This will remove all the resources that you created above.
