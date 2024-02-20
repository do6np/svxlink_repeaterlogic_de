###############################################################################
#
# Locale specific functions for playing back time, numbers and spelling words
# for svxlink_repeater_de.
#
###############################################################################

#
# Say the specified two digit number (00 - 99)
#
proc playTwoDigitNumber {number} {
  if {[string length $number] != 2} {
    puts "*** WARNING: Function playTwoDigitNumber received a non two digit number: $number";
    return;
  }
  
  set first [string index $number 0];
  if {($first == "0") || ($first == "O")} {
    playMsg "Default" $first;
    playMsg "Default" [string index $number 1];
  } elseif {$first == "1"} {
    playMsg "Default" $number;
  } elseif {[string index $number 1] == "0"} {
    playMsg "Default" $number;
  } else {
    playMsg "Default" "[string index $number 1]"; #Zeilen für deutsche Zahlen vertauscht
    playMsg "Default" "[string index $number 0]X";
  }
}


#
# Say the specified three digit number (000 - 999)
#
proc playThreeDigitNumber {number} {
  if {[string length $number] != 3} {
    puts "*** WARNING: Function playThreeDigitNumber received a non three digit number: $number";
    return;
  }
  
  set first [string index $number 0];
  if {($first == "0") || ($first == "O")} {
    spellNumber $number
  } else {
    append first "00";
    playMsg "Default" $first;
    if {[string index $number 1] != "0"} {
#      playMsg "Default" "and" # NP, 01/10/2017
      playTwoDigitNumber [string range $number 1 2];
    } elseif {[string index $number 2] != "0"} {
      playMsg "Default" "and"
      playMsg "Default" [string index $number 2];
    }
  }
}


#
# Say a number as intelligent as posible. Examples:
#
#	1	- eins
#	24	- vier und zwanzig
#	245	- zweihundert fünf und vierzig
#	1234	- eintausend zweihundert vier und dreißig
#	136.5	- einhundert sechs und dreißig Punkt fünf
#
proc playNumber {number} {
  if {[regexp {(\d+)\.(\d+)?} $number -> integer fraction]} {
    playNumber $integer;
    playMsg "Default" "decimal";
    spellNumber $fraction;
    return;
  }

  while {[string length $number] > 0} {
    set len [string length $number];
    if {$len == 1} {
      playMsg "Default" $number;
      set number "";
    } elseif {$len % 2 == 0} {
      playTwoDigitNumber [string range $number 0 1];
      set number [string range $number 2 end];
    } else {
      playThreeDigitNumber [string range $number 0 2];
      set number [string range $number 3 end];
    }
  }
}

#
# Say the time specified by function arguments "hour" and "minute".
# We ignore time setting - Germans only know 24 hour format.
proc playTime {hour minute} {
  # Strip white space and leading zeros. Check ranges.
  if {[scan $hour "%d" hour] != 1 || $hour < 0 || $hour > 23} {
    error "playTime: Non digit hour or value out of range: $hour"
  }
  if {[scan $minute "%d" minute] != 1 || $minute < 0 || $minute > 59} {
    error "playTime: Non digit minute or value out of range: $hour"
  }
  
  if {$hour == 1} {
    if [playMsg "LocalAudio" "ein" 0] {
    } else {
      playNumber $hour;
    }
  } else {
    playNumber $hour;
  }
  playMsg "LocalAudio" "uhr" 0;
  if {$minute != 0} {
    playNumber $minute;
#    playMsg "LocalAudio" "minuten" 0;
  }
}

# This file has not been truncated