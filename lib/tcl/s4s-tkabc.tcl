#
# ABC Note Renderer for TK Canvas
#

namespace eval s4s-tkabc {
	
	# Settings
	set cfg(staffheight) 40
	set cfg(notewidth)  22
	set cfg(staffwidth) 500
	set cfg(staffx) 0
	set cfg(staffy) 20
	set cfg(notepadx)  6
	set cfg(notepady)  1
	set cfg(noteeighty) 15
	set cfg(noteeightx) 8
	set cfg(noteflagdist) 8
	set cfg(clefwidth) 50
	set cfg(timescale) 16
	set cfg(notenames) "CDEFGABcdefgab"

	set notes [list C D E F G B c d e f g b]

	# calculated globals
	set cfg(staffdist) [expr {$cfg(staffheight) / 5}]
	set cfg(noteheight) [expr {$cfg(staffheight) * 0.8}]

	proc staff {path tags width} \
	{
		variable cfg

		# staff
		for {set i 0} {$i < 5} {incr i 1} {
			set y [expr {$cfg(staffy) + $i * $cfg(staffdist)}]
			set x1 [expr {$cfg(staffx) + $width}]
			$path create line $cfg(staffx) $y $x1 $y -tags $tags
		}

		#clef
		set dx [expr {$cfg(clefwidth) / 8}]
		set dy [expr {$cfg(staffheight) / 8}]

		set x0 [expr {$cfg(staffx) + $cfg(clefwidth)/2}] 
		set y0 [expr {$cfg(staffy) + $cfg(staffheight) * 3 / 5}] 
		
		set x1 [expr {$x0 - $dx * 1.5}]
		set y1 [expr {$y0 - $dy / 2}]
		set x2 [expr {$x0 + $dx / 2}]
		set y2 [expr {$y0 - $dy * 1.5}]
		set x3 [expr {$x0 + $dx}]
		set y3 [expr {$y0 + $dy}]
		set x4 [expr {$x0 - $dx}]
		set y4 [expr {$y0 + $dy * 1.5}]

		set x5 [expr {$x0 - 2 * $dx}]
		set y5 [expr {$y0 + $dy}]
		set x6 [expr {$x0 - 3 * $dx}]
		set y6 [expr {$y0}]
		set x7 [expr {$x0 + $dx}]
		set y7 [expr {$y0 - 6 * $dy}]
		set x8 [expr {$x0}]
		set y8 [expr {$y0 - 8 * $dy}]
		set x9 [expr {$x0 - $dx}]
		set y9 [expr {$y0 - 6 * $dy}]
		set x10 [expr {$x0 }]
		set y10 [expr {$y0 + 5 * $dy}]
		set x11 [expr {$x0 - $dx }]
		set y11 [expr {$y0 + 6 * $dy}]
		set x12 [expr {$x0 - 2 * $dx }]
		set y12 [expr {$y0 + 5*$dy}]


		$path create line \
			$x1 $y1 \
			$x2 $y2 \
			$x3 $y3 \
			$x4 $y4 \
			$x5 $y5 \
			$x6 $y6 \
			$x7 $y7 \
			$x8 $y8 \
			$x9 $y9 \
			$x10 $y10 \
			$x11 $y11 \
			$x12 $y12 \
			-smooth true -width 2 -tags $tags

	}

	proc barsep { path tags xpos } {
		variable cfg
		set x [expr {$cfg(staffx) + $cfg(clefwidth) + $cfg(notewidth) + $cfg(notewidth) * $xpos}]
		set y0 [expr {$cfg(staffy)}]
		set y1 [expr {$cfg(staffy) + $cfg(staffheight) * 0.8}]
		$path create line $x $y0 $x $y1 -tags $tags
	}

	proc rest { path tags xpos len } {
		variable cfg
		set x [expr {$cfg(staffx) + $cfg(clefwidth) + $cfg(notewidth) + $cfg(notewidth) * $xpos}]
		set y0 [expr {$cfg(staffy)}]
		set y1 [expr {$cfg(staffy) + $cfg(staffheight) * 0.8}]
		$path create line $x $y0 $x $y1 -tags $tags
	}

	proc note { path tags xpos ypos len } {
		variable cfg

		# base position of the note 
		set x [expr {$cfg(staffx) + $cfg(clefwidth) + $cfg(notewidth) + $cfg(notewidth) * $xpos}]
		set y [expr {$cfg(staffy) + $cfg(staffheight) - ($ypos - 2) * $cfg(staffdist) / 2}]

		# note head
		set dx [expr {$cfg(notewidth) / 2 - $cfg(notepadx)}]
		set dy [expr {$cfg(staffdist) / 2 - $cfg(notepady)}]

		set x0 [expr {$x - $dx}]
		set x1 [expr {$x + $dx}]
		set y0 [expr {$y - $dy}]
		set y1 [expr {$y + $dy}]
		
		if {$len >= 4} {
			$path create oval $x0 $y0 $x1 $y1 -fill black -tags $tags
		} else {
			$path create oval $x0 $y0 $x1 $y1 -width 2 -tags $tags
		}
		
		# note neck and flag
		if {$len >= 2} {	
			
			if {$ypos < 6} {
				set yh1 [expr {$y - $cfg(noteheight)}]
				set xh0 [expr {$x + $dx}]
				set yh2 [expr {$y - $cfg(noteheight) + $cfg(noteeighty) }]
				set xh2 [expr {$x + $dx + $cfg(noteeightx)}]
				set dfy [expr {$cfg(noteflagdist)}]
			} else {
				set yh1 [expr {$y + $cfg(noteheight)}]
				set xh0 [expr {$x - $dx}]
				set yh2 [expr {$y + $cfg(noteheight) - $cfg(noteeighty) }]
				set xh2 [expr {$x - $dx + $cfg(noteeightx)}]
				set dfy [expr {- $cfg(noteflagdist)}]
			}

			$path create line $xh0 $y $xh0 $yh1 -width 2 -tags $tags

			if {$len >= 8} {
				$path create line $xh0 $yh1 $xh2 $yh2 -width 2 -tags $tags
			}
			if {$len >= 16} {
				$path create line $xh0 [expr {$yh1 + $dfy}] $xh2 [expr {$yh2 + $dfy}] -width 2 -tags $tags
			}
			if {$len >= 32} {
				$path create line $xh0 [expr {$yh1 + $dfy * 2}] $xh2 [expr {$yh2 + $dfy * 2}] -width 2 -tags $tags
			}
		}

		# helping lines
		if {$ypos <= 2 || $ypos >= 14} {
			set dlx [expr {$cfg(notewidth) / 2 - 1}]
			set xl1 [expr {$x - $dlx}]
			set xl2 [expr {$x + $dlx}]
			set yl $y

			switch $ypos {
				0 { set yl [expr {$y - $cfg(staffdist)}] }
				1 { set yl [expr {$y - $cfg(staffdist) / 2}] }
				15 { set yl [expr {$y + $cfg(staffdist) / 2}] }
				16 { set yl [expr {$y + $cfg(staffdist)}] }
				default {}
			}

			$path create line $xl1 $yl $xl2 $yl -tags $tags

			if {$ypos == 0 || $ypos == 16} {
				$path create line $xl1 $y $xl2 $y -tags $tags
			}
		}
	}

	proc render {path tags notes args} {
		variable cfg

		# if {[winfo exists $path]} {
		# 	$path delete all
		# } else {
		# 	canvas $path {*}$args
		# }

		set matches [regexp -all -inline {([cdefgabCDEFGAB|xz])([0-9]*)} $notes]

		set staffwidth [expr {$cfg(staffx) + $cfg(notewidth) + $cfg(clefwidth)}]  
		set i 0
		foreach {match note notelen} $matches {
			set pos [expr {[string first $note $cfg(notenames)] + 2}]

			if { $notelen eq ""} {
				set notelen 1
			}

			if {$note eq "|"} {
				barsep $path $tags $i
			} elseif {$note eq "x"} {
				# pass 
			} elseif {$note eq "x"} {
				# pass 
			} else {
				note $path $tags $i $pos [expr { $cfg(timescale)/$notelen }]
			}
			incr staffwidth $cfg(notewidth)

			incr i
		}
		
		staff $path $tags $staffwidth

		return $staffwidth
	}
}

package provide s4s-tkabc 1.0