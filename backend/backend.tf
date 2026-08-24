terraform {
  backend "s3" {
    bucket       = "REPLACE_AT_INIT"
    key          = "REPLACE_AT_INIT"
    region       = "REPLACE_AT_INIT"
    use_lockfile = true
  }
}
