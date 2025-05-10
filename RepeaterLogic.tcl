###############################################################################
#
# RepeaterLogic event handlers for German language pack by DO6NP
# Tested with V1.9@25.05 - Last changed: 10-05-2025
#
###############################################################################

#
# This is the namespace in which all functions below will exist. The name
# must match the corresponding section "[RepeaterLogic]" in the configuration
# file. The name may be changed but it must be changed in both places.
#
namespace eval RepeaterLogic {

#
# Checking to see if this is the current logic core type
#
if {$logic_name != [namespace tail [namespace current]]} {
  return;
}

#
# Executed when the repeater is activated
#   reason  - The reason why the repeater was activated
#	      SQL_CLOSE	      - Open on squelch, close flank
#	      SQL_OPEN	      - Open on squelch, open flank
#	      CTCSS_CLOSE     - Open on CTCSS, squelch close flank
#	      CTCSS_OPEN      - Open on CTCSS, squelch open flank
#	      TONE	      - Open on tone burst (always on squelch close)
#	      DTMF	      - Open on DTMF digit (always on squelch close)
#	      MODULE	      - Open on module activation
#	      AUDIO	      - Open on incoming audio (module or logic linking)
#	      SQL_RPT_REOPEN  - Reopen on squelch after repeater down
#
proc repeater_up {reason} {
  #global mycall;
  #global active_module;
  global report_ctcss;
  variable repeater_is_up;

  set repeater_is_up 1;

  if {$reason != "SQL_RPT_REOPEN"} {
    set now [clock seconds];
    if {$now-$Logic::prev_ident < $Logic::min_time_between_ident} {
      return;
    } else {
      set Logic::prev_ident $now;
      Logic::send_short_ident;
      if {($reason == "CTCSS_CLOSE") || ($reason == "CTCSS_OPEN")} {
        return;
      } else {
        if {$report_ctcss > 0} {
          playSilence 50;
          if [playMsg "LocalAudio" "ctcss" 0] {
          } else {
            playMsg "Core" "pl_is";
            playFrequency $report_ctcss;
            playMsg "Core" "hz";
          }
        }
      }
    }
  }
}


#
# Executed when the repeater is deactivated
#   reason  - The reason why the repeater was deactivated
#             IDLE         - The idle timeout occured
#             SQL_FLAP_SUP - Closed due to interference
#
proc repeater_down {reason} {
  variable repeater_is_up;

  set repeater_is_up 0;

  if {$reason == "SQL_FLAP_SUP"} {
    playMsg "Core" "interference";
    playSilence 50;
    return;
  }

  set now [clock seconds];
  if {$now-$Logic::prev_ident > $Logic::min_time_between_ident} {
    Logic::send_short_ident;
  }
}


#
# Executed when there has been no activity on the repeater for
# IDLE_SOUND_INTERVAL milliseconds. This function will be called each
# IDLE_SOUND_INTERVAL millisecond until there is activity or the repeater
# is deactivated.
#
proc repeater_idle {} {
  if [playMsg "LocalAudio" "idle" 0] {
  } else {
    CW::play "K";
  }
}


#
# Executed once every whole minute to check if it's time to identify
#
proc checkPeriodicIdentify {} {
  variable repeater_is_up;
  if {$repeater_is_up} {
    Logic::checkPeriodicIdentify;
  }
}

#
# Executed if the repeater opens but the squelch never opens again.
# This is probably someone who opens the repeater but do not identify.
#
proc identify_nag {} {
  playSilence 50;
  playMsg "Core" "please_identify";
  playSilence 50;
}

# end of namespace
}

#
# This file has not been truncated
#