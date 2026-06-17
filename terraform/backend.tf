terraform {

  backend "s3" {

    bucket         = "naveen-blogging-app-terraform-state-2026"
    key            = "blogging-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-eks-naveen"

  }

}
