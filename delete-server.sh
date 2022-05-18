#!/bin/bash
hcloud volume detach storage01
hcloud server delete cas-oop-srv-01
ssh-keygen -R "95.216.218.246"
