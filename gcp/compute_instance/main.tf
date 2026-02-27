resource "google_compute_instance" "default" {
  name         = var.instance_name
  machine_type = var.instance_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    startup-script = <<EOF
#!/bin/bash
echo "user_data test" > /tmp/user_data.log
EOF
  }
}
