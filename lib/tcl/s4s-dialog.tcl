
# Options:
#
#
# -body | -content <body>
#
#   run <body> after creating the window
#
# -t | -title <title>
#
#   set window title to <title>
#
# -destroy <body>
#
#   execute <body> upon the destroing of the window
#
# -ok <body>
#
#   add an "Ok" button and an <Return> Binding which both execute <body>
#
# -cancel
#
#   add a "Cancel" botton and an <Escape> binding which both simply
#   destroy the dialog 
#
# -b | -button <title> <body>
#
#   add a new button <title> which executes <body> in a global context when pressed
#
# -sep
#
#   add a separator
#
#
# Notice:
#
#   options which add buttons add those buttons in the order which they appear.
#

proc s4s-dialog {path title button args} {
	
	# create toplevel
	toplevel $path

	set buttons [list]

	set title "Dialog"
	set content {}
	set destroy {}

	# Parameter Parsing
	set len [expr {[llength $args] - 1}] 
	for {set argidx 0} {$argidx < $len} {incr argidx} {
		set arg [lindex $args $argidx]
		switch -exact -- $arg {
			-b -
			-button {
				lappend buttons [lindex $args $argidx+1] [lindex $args $argidx+2]
				incr argidx 2
			}
			-body -
			-content {
				set content [lindex $args $argidx+1]
				incr argidx
			}
			-t -
			-title {
				set title [lindex $args $argidx+1]
				incr argidx
			}
			-destroy {
				wm protocol $path WM_DELETE_WINDOW [lindex $args $argidx+1]
				incr argidx
			}
			-cancel {
				lappend buttons "Cancel" "destroy $path"
				bind $path <Escape>      "destroy $path"
			}
			-ok {
				lappend buttons "Ok" [lindex $args $argidx+1]
				bind $path <Return>   [lindex $args $argidx+1]
				incr argidx
			}
			-sep {
				lappend buttons - {}
			}
			default {
				error "s4s-dialog: unknown parameter: '$args'"
			}
		}
	}

	if {$::tcl_platform(platform) eq "windows"} {
		wm attributes $path -topmost 1 -toolwindow 1
	}

	wm title $path $title
	wm resizable $path 0 0
	
	# create content
	uplevel 1 $content

	# lower toolbar
	frame $path.button-toolbar
	pack $path.button-toolbar -fill x
	
	set btncounter 0
	foreach {title code} $buttons {
		set elpath "$path.button-toolbar.el$btncounter"
		
		if {$title eq "-"} {
			label $elpath -text "" -width 5
		} else {
			ttk::button $elpath -text $title -command $code
		}
		
		pack $elpath -side left
		incr btncounter
	}

	tkwait window $path
}

package provide s4s-dialog 1.0