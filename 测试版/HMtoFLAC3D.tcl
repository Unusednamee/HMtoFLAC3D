set types {
	{{FLAC3D Grid File} {.f3grid}     }
}

set filename [tk_getSaveFile -title "export grid" -filetypes $types -defaultextension ".f3grid"]


if {$filename != ""} {

	set td [open $filename w]

	puts $td "*GRIDPOINTS"
	*createmark node 1 "all"
	set node_list [hm_getmark node 1]
	foreach nodes $node_list {
		puts -nonewline $td "G $nodes "
		puts $td [hm_getvalue nodes id=$nodes dataname=coordinates]
	} 

	puts $td "*ZONES"
	*createmark elems 1 "all"
	set elems_list [hm_getmark elems 1]
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

	puts $td "*GRPOUPS"
	*createmark comps 1 "all"
	set comps_list [hm_getmark comps 1]
	foreach comps $comps_list {
		set comp_name [hm_getvalue comps id=$comps dataname=name]
		puts $td "ZGROUP '$comp_name' SLOT 1"
		set zone_list [hm_getvalue comps id=$comps dataname=elements]
		set endlmark 1
		foreach zone_ $zone_list {
			if {$endlmark == 10} {
				puts $td $zone_
				set endlmark 1
			} else {
				puts -nonewline $td $zone_
				puts -nonewline $td " "
				set endlmark [expr $endlmark + 1]
			}
		}
	} 

	close $td
	
	if {$elem_miss == 0} {
		tk_messageBox -message "The FLAC3D grid has been successfully created!" \
					  -icon info -type ok
		hm_usermessage "The FLAC3D grid has been successfully created!"
	} else {
		tk_messageBox -message "There are $elem_miss elems have not be transfered.\t Because they are not belong to the valid elem type." \
					  -icon warning -type ok
		hm_usermessage "Warning : some elems have not be transfered."
	}

}
