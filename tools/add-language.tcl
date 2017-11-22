package require s4s-song 1.0

foreach {_ song} [exec s4s-ls song] {
	set song [file join $env(S4S_DATA_DIR) $song]
	if {[s4s-song::prop $song language] eq ""} {
		puts $song
		s4s-song::set-prop $song language eng
	}
}