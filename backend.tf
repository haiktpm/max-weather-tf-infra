terraform {
  backend "s3" {
    bucket         = "max-weather-states"
    key            = "maxweather.tfstate"
    region         = "ap-southeast-1"
  }
}