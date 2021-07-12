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

