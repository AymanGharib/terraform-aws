terraform {
  cloud {

    organization = "FSTT"

    workspaces {
      name = "aws"
    }
  }
}