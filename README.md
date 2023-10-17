
With the `backend` block in the `backend.tf` file commented out...
`tf apply` to create the S3 bucket and Dynamo table

Uncomment `backend` block
Replace `bucket` with output from previous apply, bucket name.
`tf init`
It will ask if you would like to copy state, select yes.

## Project setup
Move into the project dir `cd project`
`tf init`
`tf workspace new dev`
`tf apply -var-file=./vars/dev.tfvars`
`tf workspace new test`
`tf apply -var-file=./vars/test.tfvars`

After adding lambda resources, needed archive plugin
terraform init -upgrade
