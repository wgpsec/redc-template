resource "vultr_startup_script" "test" {
  name   = "man_run_docs"
  script = base64encode(file("init.sh"))
}

resource "vultr_instance" "test" {
  script_id        = vultr_startup_script.test.id
  plan             = var.plan
  region           = var.region
  os_id            = var.os_id
  label            = "tf-1"
  tags             = ["tf"]
  hostname         = "tf-1"
  enable_ipv6      = false
  backups          = "disabled"
  ddos_protection  = false
  activation_email = false
}