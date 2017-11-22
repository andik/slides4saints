
namespace eval s4s-print {
	variable outfile {}
	variable outfilename {}
	variable indentcounter 0
	variable write_header_and_footer 0

	proc begin {} {
		global env
		variable outfile
		variable outfilename
		variable write_header_and_footer

		if {[info exists env(S4S_PRINT_OUTFILE)]} {
			set outfilename $env(S4S_PRINT_OUTFILE)
			set outfile [open $outfilename a]
		} else {
			set outfile [file tempfile outfilename s4s-print-]
			set	env(S4S_PRINT_OUTFILE) $outfilename
			set write_header_and_footer 1
		}
		fconfigure $outfile -encoding utf-8

		if {$write_header_and_footer} {
			header
		}
	}

	proc header {} {
		global env
		out {<html>}
		
		tag head {} {
			out {<meta charset="utf-8">}
			tag style {type text/css} {
				set cssfile [open [file join $env(S4S_LIB_DIR) print.css] r]
				fconfigure $cssfile -encoding utf-8
				while {[gets $cssfile line] > -1} {
					out $line
				}
				close $cssfile
			}
		}

		out {<body>}
	}

	proc footer {} {
		out {</body>}
		out {</html>}
	}

	proc break {} {
		variable outfile
		close $outfile
	}

	proc resume {} {
		variable outfile
		variable outfilename
		set outfile [open $outfilename a]
	}

	proc end {} {
		variable outfile
		variable outfilename
		variable write_header_and_footer

		if {$write_header_and_footer} {
			footer
		}
		close $outfile

		if {$write_header_and_footer} {
			file rename $outfilename $outfilename.html
			
			# works only on windows...
			exec {*}[auto_execok start] {/w} [file nativename $outfilename.html]
		}

	}

	proc indent {} {
		variable indentcounter
		return [string repeat "  " $indentcounter]
	}

	proc out {s} {
		variable outfile
		puts $outfile "[indent]$s"
	}


	# TCL at it's best... recursively generate html without mess.
	proc tag {tag {attrs {}} {body {}}} {
		variable indentcounter
		variable outfile

		set pairs [lmap {k v} $attrs {
			string cat $k "=\"" $v "\"" 	
		}]

		set attrstr [join $pairs " "]
		if {$attrstr ne ""} {
			set attrstr " $attrstr"
		}

		out "<$tag$attrstr>"
		incr indentcounter 1
		uplevel 1 $body
		incr indentcounter -1
		out "</$tag>"
	}

	namespace export tag out begin end
}


package provide s4s-print 1.0