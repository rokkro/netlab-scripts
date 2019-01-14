tclsh
puts [open "flash:reset.tcl" w+] {
puts "Backing up startup-config"
typeahead ""
puts [exec "copy nvram:startup-config flash:base.cfg" ]
typeahead ""
puts "Erasing Configuration"
typeahead ""
puts [ exec "write erase" ]
typeahead ""
puts "Copying Base Configuration To Startup"
typeahead ""
puts [ exec "copy flash:base.cfg nvram:startup-config" ]
typeahead ""
puts [ exec "copy nvram:startup-config nvram:running-config" ]
typeahead ""
}
