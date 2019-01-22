puts [open "flash:reset.tcl" w+] {
puts "Backing up startup-config to flash..."
puts "(Press Enter if the script pauses here)"
typeahead "\r"
puts [exec "copy nvram:startup-config flash:base.cfg" ]
typeahead "\r"
typeahead "\r"
puts "Erasing configuration..."
typeahead "\r"
puts [ exec "write erase" ]
typeahead "\r"
puts "Copying backup to startup-config..."
typeahead "\r"
puts [ exec "copy flash:base.cfg nvram:startup-config" ]
typeahead "\r"
puts "Copying startup-config to running-config..."
typeahead "\r"
puts [ exec "copy nvram:startup-config nvram:running-config" ]
typeahead "\r"
puts "Reloading device to update settings..."
typeahead "\r"
puts [ exec "reload" ]
typeahead "\r"
}
