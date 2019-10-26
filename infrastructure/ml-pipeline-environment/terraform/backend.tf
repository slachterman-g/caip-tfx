terraform {
 backend "gcs" {
   bucket  = "jkterraform"
   prefix  = "terraform/state/jk-tfw-demo/1"
 }
}