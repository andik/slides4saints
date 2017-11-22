
namespace eval s4s-song {

	variable all_song_props [list \
		title order tempo author copyright hymn_number ccli capo key maintainer \
		language translation
	]

# ---------------------------------------------------------------------------

	proc set-entry {root entry str} {
		set fn [file join $root $entry]
		if {$str ne ""} {
			set f [open $fn "w"]
			fconfigure $f -encoding utf-8
			puts -nonewline $f [string trim $str]
			close $f
		} elseif [file exist $fn] {
			file delete $fn
		}
	}

# ---------------------------------------------------------------------------

	# reads a single file of the song into a string
	proc get-entry {root entry {default ""}} {
		set filename [file join $root $entry]
		if {[file readable $filename]} {
			set f [open $filename]
			fconfigure $f -encoding utf-8
			set data [string trim [read $f]]
			close $f
			return $data
		} else {
			return $default
		}
	}

# ---------------------------------------------------------------------------

	proc path {root type name} {
		return [file join $root $type "$name.txt"]
	}

# ---------------------------------------------------------------------------

	proc set-prop {root name value} {
		set-entry $root "property/$name.txt" $value
	}

# ---------------------------------------------------------------------------

	proc set-sec {root name value} {
		set-entry $root "section/$name.txt" $value
	}

# ---------------------------------------------------------------------------

	proc set-order {root neworder} {
		set-entry $root "property/$name.txt" [join $neworder " "]
	}

# ---------------------------------------------------------------------------

	proc prop {root name {default ""}} {
		return [get-entry $root "property/$name.txt" $default]
	}

# ---------------------------------------------------------------------------

	proc sec {root name {default ""}} {
		return [get-entry $root "section/$name.txt" $default]
	}

# ---------------------------------------------------------------------------

	proc order {root} {
		return [split [get-entry $root "property/order.txt"]]
	}

# ---------------------------------------------------------------------------

	proc sections {root} {
		set files [glob -nocomplain [file join $root "section/*.txt"]]
		return [lmap fn $files { file tail [file rootname $fn] }]
	}

# ---------------------------------------------------------------------------

	proc remove-prop {root prop} {
		file delete [file join $root "property/$prop.txt"]
	}

# ---------------------------------------------------------------------------

	proc remove-sec {root sec} {
		file delete [file join $root "section/$sec.txt"]
	}

# ---------------------------------------------------------------------------

	proc rename-sec {root from to} {
		file rename [path $root section $from] [path $root section $to]
	}

# ---------------------------------------------------------------------------

	proc foreach-sec-line {root section cmdvar restvar body} {
		upvar 1 $cmdvar cmd
		upvar 1 $restvar rest

		set f [open [file join $root "section/$section.txt"]]
		fconfigure $f -encoding utf-8
		while {[gets $f line] >= 0} {
			if {[regexp {^(\w+)\s*(.*)} $line _ cmd rest]} {
				uplevel 1 $body
			} elseif {$line ne ""} {
				puts stderr "error \"$line\""
			}
		}
		close $f
	}

# ---------------------------------------------------------------------------

	proc all-props {} {
		variable all_song_props
		return $all_song_props
	}
}


package provide s4s-song 1.0