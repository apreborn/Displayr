
## Steps to run Terraform
```
terraform init
terraform plan -var-file=aws.tfvars
terraform apply -var-file=aws.tfvars -auto-approve
```
- Once the `terrform apply` completed successfully it will show the `public ipaddress` of the apache server as `output`

```
aws_instance.web: Creation complete after 1m20s [id=i-00db079ee111fc053]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

web_instance_ip = 13.54.227.26
``` 
## Access the Webserver
- We can access the webserver using the public IP
- Screenshot Below,

![Apache WebServer Page](https://github.com/chefgs/repo_images/blob/master/apache2page.png?raw=true)

.
