toplevel .mytop

label .mytop.lab1 -text "Choose components to export." -height 3
pack .mytop.lab1 -side top

set sl [hwtk::selectlist .mytop.list -stripes 1 -selectmode multiple ]
pack $sl -fill both -expand true
$sl columnadd components -text Entity
$sl columnadd id -text ID
$sl columnadd color -image palette-16.png

listbox .mytop.lb -height 3 -width 150
pack .mytop.lb -side bottom

set b1 [hwtk::button .mytop.lb.btn1 -text "export" -default active]
set b2 [hwtk::button .mytop.lb.btn2 -text "cancel"]

pack $b1 -side right
pack $b2 -side left

*createmark comps 1 "all"
set comps_list [hm_getmark comps 1]

foreach comps $comps_list {
	
	set comp_name [hm_getvalue comps id=$comps dataname=name]
	set comp_color [hm_getvalue comps id=$comps dataname=color]
    $sl rowadd $comp_name -values [list components $comp_name id $comps color $comp_color ]
}

proc btnCancel {x} {
    destroy $x
}

proc btnExport {x sl} {
	set types {
		{{FLAC3D Grid File} {.f3grid}     }
	}

	set filename [tk_getSaveFile -title "export grid" -filetypes $types -defaultextension ".f3grid"]
	set comps_list [$sl selectionget]
	
	destroy $x

	if {$filename != ""} {
	
		toplevel .executing -borderwidth 50
		label .executing.lab1 -text "Executing,please wait..." -height 3
		pack .executing.lab1 -side top
		hwtk::progressbar .executing.pi -mode indeterminate
		pack .executing.pi 
		.executing.pi start 
	
		set td [open $filename w]

		puts $td "*GRIDPOINTS"
		hm_createmark node 1 "by comp name" $comps_list
		
		set node_list [hm_getmark node 1]
		foreach nodes $node_list {
			puts -nonewline $td "G $nodes "
			puts $td [hm_getvalue nodes id=$nodes dataname=coordinates]
		} 

		puts $td "*ZONES"
		foreach comps $comps_list {
			set elems_list [hm_getvalue comps name=$comps dataname=elements]
			set elem_miss 0
			foreach elems $elems_list {
				set con [hm_getvalue elems id=$elems dataname=config]
				if {$con == 208} {
					set point_list [hm_getvalue elems id=$elems dataname=nodes]
					puts -nonewline $td "Z B8 $elems "
					puts -nonewline $td [lindex $point_list 0]
					puts -nonewline $td " "
					puts -nonewline $td [lindex $point_list 1]
					puts -nonewline $td " "
					puts -nonewline $td [lindex $point_list 3]
					puts -nonewline $td " "
					puts -nonewline $td [lindex $point_list 4]
					puts -nonewline $td " "
					puts -nonewline $td [lindex $point_list 2]
					puts -nonewline $td " "
					puts -nonewline $td [lindex $point_list 7]
					puts -nonewline $td " "
					puts -nonewline $td [lindex $point_list 5]
					puts -nonewline $td " "
					puts $td [lindex $point_list 6]
				} elseif {$con == 206} {
					set point_list [hm_getvalue elems id=$elems dataname=nodes]
					puts -nonewline $td "Z W6 $elems "
					puts -nonewline $td [lindex $point_list 0]
					puts -nonewline $td " "
					puts -nonewline $td [lindex $point_list 2]
					puts -nonewline $td " "
					puts -nonewline $td [lindex $point_list 3]
					puts -nonewline $td " "
					puts -nonewline $td [lindex $point_list 1]
					puts -nonewline $td " "
					puts -nonewline $td [lindex $point_list 5]
					puts -nonewline $td " "
					puts $td [lindex $point_list 4]
				} elseif {$con == 204} {
					puts -nonewline $td "Z T4 $elems "
					puts $td [hm_getvalue elems id=$elems dataname=nodes]
				} else {
					set elem_miss [expr $elem_miss + 1]		
				} 
			} 
		} 

		puts $td "*GRPOUPS"
		foreach comps $comps_list {
			set zone_list [hm_getvalue comps name=$comps dataname=elements]
			if {$zone_list eq ""} {
				continue
			}
			
			puts $td "ZGROUP '$comps'"
			
			set endlmark 1
			foreach zone_ $zone_list {
				set con [hm_getvalue elems id=$zone_ dataname=config]
				if {$con != 208 && $con != 206 && $con != 204} {
					continue
				}
				if {$endlmark == 10} {
					puts $td $zone_
					set endlmark 1
				} else {
					puts -nonewline $td "$zone_ "
					set endlmark [expr $endlmark + 1]
				}
			}
			if {$endlmark != 1} {
				puts $td " "
			}
		} 

		close $td
		
		destroy .executing
		
		if {$elem_miss == 0} {
			tk_messageBox -message "The FLAC3D grid has been successfully created!" \
						  -icon info -type ok
			hm_usermessage "The FLAC3D grid has been successfully created!"
		} else {
			tk_messageBox -message "There are $elem_miss elems have not be transfered.\n Because they are not belong to the valid elem type." \
						  -icon warning -type ok
			hm_usermessage "Warning : some elems have not be transfered."
		}

	}

}

$b2 configure -command "btnCancel .mytop" 
$b1 configure -command "btnExport .mytop $sl" 


