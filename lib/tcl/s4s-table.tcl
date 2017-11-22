#
# a treeview-table which is autofilled from a list with selection and search
# support.
#

namespace eval s4s-table {
	variable all_listboxes [dict create]

	# ----------------------------------------------------------------------

	proc create {path columns elems} {
		variable all_listboxes

		frame $path

		#ttk::scrollbar $f.hsb -orient horizontal -command [list $f.t xview]
		ttk::scrollbar $path.vsb -orient vertical -command [list $path.tv yview]
		ttk::treeview $path.tv -columns $columns -show headings -yscrollcommand [list $path.vsb set]
		#-xscrollcommand [list $path.vsb set]

		pack $path.vsb -side right -fill y 
		pack $path.tv -fill both -expand 1

		foreach col $columns {
			$path.tv column $col -minwidth 10 -stretch 1
			$path.tv heading $col -text $col
		}

		dict set all_listboxes $path [dict create columns $columns elems $elems filter "" filtercol 0]

		set-filter $path "" 0

		# Focus the selected element when getting the focus.. fixes a ttk problem
		bind $path.tv <FocusIn> {
			set sel [lindex [%W selection] 0]
			%W focus $sel
			%W see $sel
		}
	}

	# ----------------------------------------------------------------------

	proc set-elems {path elems} {
		variable all_listboxes
		dict set all_listboxes $path elems $elems
		update-all $path
	}

	# ----------------------------------------------------------------------

	proc get-elems {path} {
		variable all_listboxes
		return [dict get $all_listboxes $path elems]
	}

	# ----------------------------------------------------------------------

	proc set-filter {path filter column} {
		variable all_listboxes
		dict set all_listboxes $path filter $filter
		dict set all_listboxes $path filtercol $column
		update-all $path
	}

	# ----------------------------------------------------------------------

	proc update-all {path} {
		variable all_listboxes
		set filter [dict get $all_listboxes $path filter]
		set column [dict get $all_listboxes $path filtercol]
	
		$path.tv delete [$path.tv tag has all]

		if {$filter eq ""} {
			# no filter is set: simple add all elements
			foreach el [get-elems $path] {
				$path.tv insert {} end -values $el -tags all
			}
		} else {
			# filter is set: filter elemts
			set pattern "*[join [split $filter ""] "*"]*"
			foreach el [get-elems $path] {
				set name [lindex $el $column]
				if {[string match -nocase $pattern $name]} {
					$path.tv insert {} end -values $el -tags all
				}
			}
		}

		# reset selection if any element passed the filter
		if {[llength [$path.tv tag has all]] > 0} {
			$path.tv selection set [lindex [$path.tv tag has all] 0]
		}
	}

	# ----------------------------------------------------------------------

	# index in elems list...
	proc selected-index {path} {
		set sel [lindex [$path.tv selection] 0]
		if {$sel ne ""} {
			return [$path index $sel]
		}
		return -1
	}

	# ----------------------------------------------------------------------

	proc selected-elem {path} {
		set sel [lindex [$path.tv selection] 0]
		if {$sel ne ""} {
			return [$path.tv item $sel -values]
		}
		return {}
	}
	
	# ----------------------------------------------------------------------

	proc move-prev {path} {
		set sel [lindex [$path.tv selection] 0]
		set sel [$path.tv prev $sel]
		move-to $path $sel
	}

	# ----------------------------------------------------------------------

	proc move-next {path} {
		set sel [lindex [$path.tv selection] 0]
		set sel [$path.tv next $sel]
		move-to $path $sel
	}

	# ----------------------------------------------------------------------

	proc move-to {path sel} {
		if {$sel ne ""} {
			$path.tv selection set $sel
			$path.tv focus $sel ;# fix fuer ein tk problem
			$path.tv see $sel ;# fix fuer ein tk problem
		}
	}

}

package provide s4s-table 1.0