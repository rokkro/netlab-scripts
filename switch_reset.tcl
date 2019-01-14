puts [open "flash:reset.tcl" w+] {
puts "Backing up startup-config..."
typeahead ""
puts [exec "copy nvram:startup-config flash:base.cfg" ]
puts "Erasing configuration..."
typeahead ""
puts [ exec "write erase" ]
puts "Erasing VLAN database..."
typeahead ""
puts [ exec "del flash:vlan.dat" ]
puts "Copying backup to startup-config..."
typeahead ""
puts [ exec "copy flash:base.cfg nvram:startup-config" ]
typeahead ""
puts "Copying startup-config to running-config..."
typeahead ""
puts [ exec "copy nvram:startup-config nvram:running-config" ]
typeahead ""
puts "Reloading device to generate new VLAN Database..."
typeahead ""
puts [ exec "reload" ]
typeahead ""
}
