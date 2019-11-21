provider "google" {
  credentials = "${file("active-freehold-213921-99f4f141d7eb.json")}"
  project     = "active-freehold-213921"
}

resource "google_compute_network" "vpc" {
  name          =  "myVPC"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}

resource "google_compute_firewall" "allow-internal" {
  name    = "company-name-fw-allow-internal"
  network = "${google_compute_network.vpc.name}"
  
allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
}

resource "google_compute_firewall" "allow-http" {
  name    = "company-name-fw-allow-http"
  network = "${google_compute_network.vpc.name}"

allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["http"] 
}

resource "google_compute_firewall" "allow-bastion" {
  name    = "company-name-fw-allow-bastion"
  network = "${google_compute_network.vpc.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["ssh"]
  }

resource "google_compute_subnetwork" "public_subnet" {
  name          =  "mypublicsubnet"
  ip_cidr_range = "10.26.2.0/24"
  network       = google_compute_network.vpc.self_link
  region        = "us-west1"
}

resource "google_compute_subnetwork" "private_subnet" {
  name          =  "myprivatesubnet"
  ip_cidr_range = "10.26.1.0/24"
  network       = google_compute_network.vpc.self_link
  region        = "us-west1"
}

resource "google_compute_instance" "test-instance" {
  name         = "myVM"
  machine_type  = "f1-micro"
  
  boot_disk {
    initialize_params {
      image     =  "centos-7-v20170816"     
    }
	}
network_interface {
    subnetwork = "${google_compute_subnetwork.public_subnet.name}"
    access_config {
      }
  }
}

