#
# Pencil functionality for s4s-canvas using combined mode and
# objects.
#

namespace eval s4s-canvas-pencil {
	variable name_to_style [dict create]
	variable last_x  [dict create]
	variable last_y  [dict create]
	variable first_x [dict create]
	variable first_y [dict create]
	variable pencilobj  [dict create]

	# ---------------------------------------------------------------------------

	proc register-style {style args} {
		variable name_to_style
		dict set name_to_style $style $args
	}

	# ---------------------------------------------------------------------------

	proc hookup {path style} {
		s4s-canvas::register-obj  $path $style "s4s-canvas-pencil::draw $style"
		s4s-canvas::register-mode $path $style  \
			"s4s-canvas-pencil::on-press $style" \
			"s4s-canvas-pencil::on-move $style" \
			"s4s-canvas-pencil::on-release $style"
	}

	# ---------------------------------------------------------------------------

	proc draw {style path x y points} {
		variable name_to_style
		# make relative coordinates absolute
		set points [points-absolute $x $y $points]
		set penargs [dict get $name_to_style $style]
		return [$path create line $points {*}$penargs]
	}

	# ---------------------------------------------------------------------------

	proc on-move {style path x y} {
		# extend the coordinate list of the line
		set coords [concat [$path coords [pencil $path]] $x $y]
		$path coords [pencil $path] $coords
	}

	# ---------------------------------------------------------------------------

	proc on-press {style path x y} {
		variable name_to_style
		first-x $path $x
		first-y $path $y
		# create the object we want to edit
		set penargs [dict get $name_to_style $style]
		set-pencil $path [$path create line $x $y $x $y {*}$penargs]
	}

	# ---------------------------------------------------------------------------

	proc on-release {style path x y} {
		set x0 [first-x $path] 
		set y0 [first-y $path]

		set points [points-relative-to $x0 $y0 [$path coords [pencil $path]]]

		s4s-canvas::hookup-tag $path [pencil $path] [list line $x0 $y0 $points]
	}

	# ---------------------------------------------------------------------------

	proc handle-xy {path varname args} {
		variable $varname
		if {[llength $args] > 0} {
			return [dict set $varname $path [lindex $args 0]]
		} else {
			return [dict get [set $varname] $path]
		}
	}

	# ---------------------------------------------------------------------------

	proc first-x {path args} {
		return [handle-xy $path first_x {*}$args]
	}

	# ---------------------------------------------------------------------------

	proc first-y {path args} {
		return [handle-xy $path first_y {*}$args]
	}

	# ---------------------------------------------------------------------------

	proc points-relative-to {x y absolute_points} {
		return [concat {*}[lmap {px py} $absolute_points { 
			list [expr {$px-$x}] [expr {$py-$y}]
		}]]
	}

	# ---------------------------------------------------------------------------

	proc points-absolute {root_x root_y relative_points} {
		return [concat {*}[lmap {px py} $relative_points { 
			list [expr {$root_x+$px}] [expr {$root_y+$py}]
		}]]
	}

	# ---------------------------------------------------------------------------

	proc set-pencil {path obj} {
		variable pencilobj
		dict set pencilobj $path $obj
	}
	
	# ---------------------------------------------------------------------------

	proc pencil {path} {
		variable pencilobj
		return [dict get $pencilobj $path]
	}

}

package provide s4s-canvas-pencil 1.0