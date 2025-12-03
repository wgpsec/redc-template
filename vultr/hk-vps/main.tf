resource "vultr_startup_script" "test" {
    name = "man_run_docs"
    script = base64encode(file("init.sh"))
}

resource "vultr_instance" "test" {
    script_id = vultr_startup_script.test.id
    plan = "vc2-1c-2gb"
    region = "sgp"
    os_id = 477
    label = "tf-1"
    tags = ["tf"]
    hostname = "tf-1"
    enable_ipv6 = false
    backups = "disabled"
    ddos_protection = false
    activation_email = false
}