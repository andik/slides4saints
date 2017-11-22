package require s4s-debug 1.0

namespace eval s4s-canvas {
	variable selection
	variable mode
	variable modes [list none edit]
	variable obj_to_draw_func    [dict create]
	variable mode_callbacks      [dict create]
	variable object_types        [dict create]
	variable object_args         [dict create]
	variable defaultargs         [dict create]
	variable prev_x 0
	variable prev_y 0

	namespace export hookup draw register

	proc hookup {path} {
		variable objcounter
		variable mode

		bind $path <ButtonPress-1>   { s4s-canvas::on-press   %W %x %y; break }
		bind $path <B1-Motion>       { s4s-canvas::on-move    %W %x %y; break }
		bind $path <ButtonRelease-1> { s4s-canvas::on-release %W %x %y; break }

		set mode($path) none

		register-mode $path none on-press(none) on-move(none) on-release(none)
		register-mode $path edit on-press(edit) on-move(edit) on-release(edit)
	}

	# ---------------------------------------------------------------------------

	proc reset {path} {
		variable obj_to_draw_func
		variable mode_callbacks
		variable object_types
		variable object_args
		variable defaultargs
		dict set obj_to_draw_func $path {}
		dict set mode_callbacks $path {}
		dict set object_types $path {}
		dict set object_args $path {}
		dict set defaultargs $path {}
	}

	# ---------------------------------------------------------------------------

	proc on-press {path args} {
		variable mode_callbacks
		variable mode
		set curmode [set mode($path)]
		set callback [dict get $mode_callbacks $path $curmode press]

		if {$callback ne {}} {
			eval $callback $path $args
		}
	}

	# ---------------------------------------------------------------------------

	proc on-move {path args} {
		variable mode_callbacks
		variable mode
		set curmode [set mode($path)]
		set callback [dict get $mode_callbacks $path $curmode pressmove]

		if {$callback ne {}} {
			eval $callback $path $args
		}
	}

	# ---------------------------------------------------------------------------

	proc on-release {path args} {
		variable mode_callbacks
		variable mode
		set curmode [set mode($path)]
		set callback [dict get $mode_callbacks $path $curmode release]

		if {$callback ne {}} {
			eval $callback $path $args
		}
	}

	# ---------------------------------------------------------------------------

	proc on-move(none) {path x y} {}
	proc on-press(none) {path x y} {}
	proc on-release(none) {path x y} {}

	# ---------------------------------------------------------------------------

	proc on-press(edit) {path x y} {
		variable selection
		variable prev_x
		variable prev_y
		if {[selection $path] ne ""} {
			set prev_x $x
			set prev_y $y
		}
	}

	# ---------------------------------------------------------------------------

	proc on-move(edit) {path x y} {
		variable selection
		variable prev_x
		variable prev_y

		if {[selection $path] ne ""} {
			set dx [expr {$x - $prev_x}] 
			set dy [expr {$y - $prev_y}]
			foreach obj [selection $path] {
				$path move $obj $dx $dy
			}
			$path move s4s-canvas-selbox $dx $dy
		}
		
		set prev_x $x
		set prev_y $y
	}

	# ---------------------------------------------------------------------------

	proc on-release(edit) {path x y} {
		variable object_args

		# update object in internal storage
		foreach tag [selection $path] {
			if {$tag ne ""} {
				set tagargs [dict get $object_args $path $tag]
				set tagargs [lreplace $tagargs 1 2 $x $y]
				dict set object_args $path $tag $tagargs
			}
		}

		update-selection $path $x $y
	}

	# ---------------------------------------------------------------------------

	proc update-selection {path x y} {
		variable selection
		variable object_args
		
		set sel [object-hit $path $x $y]
		set elems [dict keys $object_args]

		set sel [lindex $sel 0]
		foreach id [concat [$path gettags $sel] $sel] {
			if {([dict exists $object_args $path $id] > -1) && ($id ne "current")} {
				set sel $id
				break
			}
		}

		# lsort on an empty list returns "{}"
		if {$sel ne ""} {
			selection $path [list $sel]
		} else {
			selection $path [list]
		}
	}
	
	# ---------------------------------------------------------------------------

	proc selection {path args} {
		variable selection
		if {[llength $args] > 0} {
			set selection($path) [lindex $args 0]
			update-selbox $path
		} elseif {[info exists selection($path)]} {
			return [set selection($path)]
		} else {
			return [list]
		}
	}

	# ---------------------------------------------------------------------------

	proc update-selbox {path} {
		$path delete s4s-canvas-selbox
		set sel [selection $path]
		if {[llength $sel] > 0} {
			set bbox [$path bbox {*}$sel]
			if {[llength $bbox] > 0} {
				$path create rect $bbox -outline #00f -width 4 -tag s4s-canvas-selbox
			}
		}
	}
	
	# ---------------------------------------------------------------------------

	proc unselect {path} {
		variable selection
		dict set selection($path) {}
		$path delete s4s-canvas-selbox
	}

	# ---------------------------------------------------------------------------

	proc draw {path type x y args} {
		variable obj_to_draw_func 
		variable object_args 
		variable defaultargs
		if {[dict exists $obj_to_draw_func $path $type]} {
			set cmd [dict get $obj_to_draw_func $path $type]
			set defargs [dict get $defaultargs $path $type]
			# run callback function
			set obj [eval $cmd $path $x $y $args $defargs]
			# add object to internal registry
			hookup-tag $path $obj $type $x $y {*}$args
			return $obj
		} else {
			error "s4s-canvas: no handler '$type' registered for canvas $path"
		}
	}

	# ---------------------------------------------------------------------------

	proc register-mode {path name press pressmove release} {
		variable mode_callbacks
		variable modes
		lappend modes $name
		dict set mode_callbacks $path $name press     $press
		dict set mode_callbacks $path $name pressmove $pressmove
		dict set mode_callbacks $path $name release   $release
	}

	# ---------------------------------------------------------------------------

	# register functions for 'draw'. must be procs of type 'path x y args'
	# path must be global reachable or within this namespace
	proc register-obj {path type func args} {
		variable obj_to_draw_func
		variable defaultargs
		dict set obj_to_draw_func $path $type $func
		dict set defaultargs $path $type $args
	}
	
	# ---------------------------------------------------------------------------

	proc object-hit {path x y {type ""}} {
		set x1 [expr {$x-2}]
		set x2 [expr {$x+2}]
		set y1 [expr {$y-2}]
		set y2 [expr {$y+2}]
		set objs [$path find overlapping  $x1 $y1 $x2 $y2]
		if {$type eq {}} {
			return $objs
		} else {
			return [lmap o $objs {expr \
				{ [$path type $o] eq $type ? $o : [continue]  }}]
		}
	}

	# ---------------------------------------------------------------------------

	proc hookup-tag {path tag type args} {
		variable object_args
		dict set object_args  $path $tag [concat $type $args]
		return $tag
	}

	# ---------------------------------------------------------------------------

	proc dump {path} {
		variable object_args
		return [dict get $object_args $path]
	}

	# ---------------------------------------------------------------------------

	proc delete-selected {path} {
		variable object_args
		set tag [selection $path]
		$path delete $tag
		dict unset object_args $path $tag
		selection $path {}
	}

	# ---------------------------------------------------------------------------

	proc set-mode {path nextmode} {
		variable mode
		set mode($path) $nextmode
	}

}

package provide s4s-canvas 1.0

