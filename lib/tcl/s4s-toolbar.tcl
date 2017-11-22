proc s4s-toolbar {tkpath args} {
	# Configuration Options
	set commonparams [list]

	# Parameter Parsing
	set len [expr {[llength $args] - 1}] 
	for {set i 0} {$i < $len} {incr i} {
		set arg [lindex $args $i]
		switch -exact -- $arg {
			-common {
				set commonparams [lindex $args $i+1]
				incr i
			}
			default {
				error "invalid parameter: $arg"
			}
		}
	}

	set buttons [lindex $args end]
	set counter 0

	pack [frame $tkpath] -fill x
	foreach {widget text cmd params} $buttons {
		set elpath "$tkpath.e$counter"
		if {$widget eq "-"} {
			ttk::label $elpath -text "" -width 2
		} else {
			$widget $elpath -text $text -command $cmd {*}$commonparams {*}$params
		}
		pack $elpath -side left
		incr counter
	}
}

package provide s4s-toolbar 1.0