namespace eval s4s-set {


	proc foreach-setlist-entry {setlist typevar filevar paramsvar body} {
		upvar 1 $typevar type
		upvar 1 $filevar file
		upvar 1 $paramsvar params
		global env
		
		set f [open $setlist]

		set lineNumber 0
		while {[gets $f line] >= 0} {
		  if {[regexp {^\w+\s+.*} $line]} {
		  	set args [list {*}$line]
		  	set type [lindex $args 0]
		  	set file [file join $env(S4S_DATA_DIR) [lindex $args end]]
		  	set params [lrange $args 1 end]
		    uplevel 1 $body
		  } elseif {[regexp {^#} $line]} {
		  	# ignored
		  } else {
		  	error "invalid S4S Setlist line format: '$line'"
		  }
		}

		close $f
	}
}

package provide s4s-set 1.0