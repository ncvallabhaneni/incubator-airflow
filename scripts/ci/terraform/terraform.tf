terraform {
 backend "s3" {
 encrypt = true
 bucket = "terraform-remote-state-storage-s3"
 region = "ap-south-1"
 key = "path/to/state/file"
 }
}
