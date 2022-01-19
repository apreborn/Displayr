
## Steps to run Terraform
```
terraform init
terraform plan -var-file=aws.tfvars
terraform apply -var-file=aws.tfvars -auto-approve
```
- Once the `terrform apply` completed successfully it will show the `public ipaddress` of the apache server as `output`

```
aws_instance.web: Creation complete after 33s [id=i-07f19000878a6ec11]

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

web_instance_ip = "34.220.248.140"
``` 
## Access the Webserver
- We can access the webserver using the public IP
- Screenshot Below,

![Apache WebServer Page](https://github.com/chefgs/repo_images/blob/master/apache2page.png?raw=true)

.
