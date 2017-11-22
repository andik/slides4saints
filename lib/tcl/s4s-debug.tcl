namespace eval s4s-debug {

    proc break {{s {}}} {
        if ![info exists ::bp_skip] {
           set ::bp_skip [list]
        } elseif {[lsearch -exact $::bp_skip $s]>=0} return
        if [catch {info level -1} who] {set who ::}
        while 1 {
                puts -nonewline "$who/$s> "; flush stdout
                gets stdin line
                if {$line=="c"} {puts "continuing.."; break}
                if {$line=="i"} {set line "info locals"}
                catch {uplevel 1 $line} res
                puts $res
        }
    }

    proc locals {args} {
        puts ""
        puts "s4s-debug::locals $args {"
        uplevel 1 {
            foreach var [info locals] {
                puts "  $var [set $var]"
            }
        }
        puts "}"
    }
}

package provide s4s-debug 1.0