variable "node" {
  type        = number
  description = "node count"
}

variable "ddos_target" {
  type        = string
  description = "ddos target"
}

variable "ddos_threads" {
  type        = string
  description = "ddos threads"
}

variable "ddos_time" {
  type        = string
  description = "ddos time"
}

variable "ddos_mode" {
  type        = string
  description = "APACHE / COOKIE / BYPASS / DOWNLOADER / POST / XMLRPC"
}