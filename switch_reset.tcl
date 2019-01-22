puts [open "flash:reset.tcl" w+] {
puts "Backing up startup-config to flash..."
typeahead "\r"
puts [exec "copy nvram:startup-config flash:base.cfg" ]
puts "Erasing configuration..."
typeahead "\r"
puts [ exec "write erase" ]
puts "Erasing VLAN database from flash..."
typeahead "\r"
puts [ exec "del flash:vlan.dat" ]
puts "Copying backup to startup-config..."
typeahead "\r"
puts [ exec "copy flash:base.cfg nvram:startup-config" ]
typeahead "\r"
puts "Copying startup-config to running-config..."
typeahead "\r"
puts [ exec "copy nvram:startup-config nvram:running-config" ]
typeahead "\r"
puts "Reloading device to generate new VLAN Database..."
typeahead "\r"
puts [ exec "reload" ]
typeahead "\r"
}
