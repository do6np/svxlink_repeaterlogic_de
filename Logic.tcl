###############################################################################
#
# Generic Logic event handlers for German language pack by DO6NP
# Tested with V1.9@25.05 - Last changed: 10-05-2025
#
###############################################################################

#
# This is the namespace in which all functions and variables below will exist.
#
namespace eval Logic {

#
# Set some new variables
#
variable min_time_between_ident 300;

#
# Some new variables defined in /etc/svxlink/svxlink.d/iao.conf
#
variable rgr_sound_amp -16;
variable rgr_sound_pitch 1000;
variable rgr_sound_cpm 120;
variable rgr_sound_tonelength 150;
variable rgr_sound_rx_id 0;
variable cw_first 1;

#
# Executed when the SvxLink software is started
#
proc startup {} {
  #playMsg "Core" "online";
  send_short_ident;
  CW::play "qrv";
}

#
# Executed when a manual identification is initiated with the * DTMF code
#
proc manual_identification {} {
  global mycall;
  global report_ctcss;
  global active_module;
  global loaded_modules;
  variable prev_ident;

  set epoch [clock seconds];
  set hour [clock format $epoch -format "%k"];
  regexp {([1-5]?\d)$} [clock format $epoch -format "%M"] -> minute;
  set prev_ident $epoch;

  playMsg "LocalAudio" $mycall;
  playSilence 50;
  playMsg "Core" "the_time_is";
  playTime $hour $minute;
  if {$report_ctcss > 0} {
    playSilence 50;
    if [playMsg "LocalAudio" "ctcss" 0] {
    } else {
      playMsg "Core" "pl_is";
      playFrequency $report_ctcss;
      playMsg "Core" "hz";
    }
  }
  if {$active_module != ""} {
    playSilence 50;
    playMsg "Core" "active_module";
    playMsg $active_module "name";
    playSilence 50;
    set func "::";
    append func $active_module "::status_report";
    if {"[info procs $func]" ne ""} {
      $func;
    }
  } else {
    foreach module [split $loaded_modules " "] {
      set func "::";
      append func $module "::status_report";
      if {"[info procs $func]" ne ""} {
        $func;
      }
    }
  }
}

#
# Executed when a short identification should be sent
#   hour    - The hour on which this identification occur
#   minute  - The minute on which this identification occur
#
proc send_short_ident {{hour -1} {minute -1}} {
  global mycall;
  variable short_announce_file
  variable short_announce_enable
  variable short_voice_id_enable
  variable short_cw_id_enable
  variable cw_first

  if {$cw_first} {
    # Play CW id if enabled
    if {$short_cw_id_enable} {
      puts "Playing short CW ID first"
      if [playMsg "LocalAudio" "{$mycall}_cw" 0] {
      } else {
        CW::play $mycall
      }
    }
  }

  # Play voice id if enabled
  if {$short_voice_id_enable} {
    puts "Playing short voice ID"
    if [playMsg "LocalAudio" $mycall 0] {
    } else {
      spellWord $mycall
    }
  }

  if {!$cw_first} {
    if {$short_cw_id_enable} {
      puts "Playing short CW ID first"
      playSilence 50;
      if [playMsg "LocalAudio" "{$mycall}_cw" 0] {
      } else {
        CW::play $mycall
      }
    }
  }

  # Play announcement file if enabled
  if {$short_announce_enable} {
    puts "Playing short announce"
    if [file exist "$short_announce_file"] {
      playSilence 50
      playFile "$short_announce_file"
    }
  }
}

#
# Executed when a long identification (e.g. hourly) should be sent
#   hour    - The hour on which this identification occur
#   minute  - The minute on which this identification occur
#
proc send_long_ident {hour minute} {
  global mycall;
  global loaded_modules;
  global active_module;
  global report_ctcss;
  variable long_announce_file
  variable long_announce_enable
  variable long_voice_id_enable
  variable long_voice_id_time
  variable long_voice_id_module
  variable long_cw_id_enable
  variable cw_first

  # Play CW id if enabled
  if {$cw_first} {
    if {$long_cw_id_enable} {
      puts "Playing long CW ID first"
      if [playMsg "LocalAudio" "{$mycall}_cw" 0] {
      } else {
        CW::play $mycall
      }
    }
  }

  # Play the voice ID if enabled (1st part)
  if {$long_voice_id_enable} {
    puts "Playing Long voice ID"
    if [playMsg "LocalAudio" $mycall 0] {
    } else {
      spellWord $mycall
    }
  }

  # Play CW id if enabled
  if {!$cw_first} {
    if {$long_cw_id_enable} {
      puts "Playing long CW ID second"
      playSilence 50;
      if [playMsg "LocalAudio" "{$mycall}_cw" 0] {
      } else {
        CW::play $mycall
      }
    }
  }

  # Play the voice ID if enabled (2nd part)
  if {$long_voice_id_enable} {
    if {$long_voice_id_time} {
      playSilence 50;
      if [playMsg "LocalAudio" "clock" 0] {
        playSilence 250;
      } else {
        playMsg "Core" "the_time_is";
      }
      playTime $hour $minute;
    }
    if {$report_ctcss > 0} {
      playSilence 50;
      if [playMsg "LocalAudio" "ctcss" 0] {
      } else {
        playMsg "Core" "pl_is";
        playFrequency $report_ctcss;
        playMsg "Core" "hz";
      }
    }

    # Call the "status_report" function in all modules if no module is active
    if {$long_voice_id_module} {
      if {$active_module != ""} {
        playSilence 50;
        playMsg "Core" "active_module";
        playMsg $active_module "name";
        playSilence 50;
        set func "::";
        append func $active_module "::status_report";
        if {"[info procs $func]" ne ""} {
          $func;
        }
      } else {
        foreach module [split $loaded_modules " "] {
          set func "::";
          append func $module "::status_report";
          if {"[info procs $func]" ne ""} {
            $func;
          }
        }
      }
    }
  }

  # Play announcement file if enabled
  if {$long_announce_enable} {
    if [file exist "$long_announce_file"] {
      puts "Playing long announce"
      playSilence 50;
      playFile "$long_announce_file"
    }
  }
}

#
# Executed when the squelch have just closed and the RGR_SOUND_DELAY timer has
# expired.
#
proc send_rgr_sound {} {
  variable rgr_sound_amp;
  variable rgr_sound_pitch;
  variable rgr_sound_cpm;
  variable rgr_sound_tonelength;
  variable rgr_sound_rx_id;
  variable sql_rx_id;
  if {$sql_rx_id != "?"} {
    if {$rgr_sound_rx_id} {
      CW::play $sql_rx_id $rgr_sound_cpm $rgr_sound_pitch $rgr_sound_amp;
    } else {
      playTone $rgr_sound_pitch $rgr_sound_amp $rgr_sound_tonelength;
    }
    set sql_rx_id "?"
  } else {
    playTone $rgr_sound_pitch $rgr_sound_amp $rgr_sound_tonelength;
  }
}

#
# Executed when a link to another logic core is activated.
#   name  - The name of the link
#
proc activating_link {name} {
  if {[string length $name] > 0} {
    playMsg "Core" "activating_link_to";
    if [playMsg "LocalAudio" "$name" 0] {
    } else {
      spellWord $name;
    }
  }
}

#
# Executed when a link to another logic core is deactivated.
#   name  - The name of the link
#
proc deactivating_link {name} {
  if {[string length $name] > 0} {
    playMsg "Core" "deactivating_link_to";
    if [playMsg "LocalAudio" "$name" 0] {
    } else {
      spellWord $name;
    }
  }
}

#
# Executed when trying to deactivate a link to another logic core but the
# link is not currently active.
#   name  - The name of the link
#
proc link_not_active {name} {
  if {[string length $name] > 0} {
    playMsg "Core" "link_not_active_to";
    if [playMsg "LocalAudio" "$name" 0] {
    } else {
      spellWord $name;
    }
  }
}

#
# Executed when trying to activate a link to another logic core but the
# link is already active.
#   name  - The name of the link
#
proc link_already_active {name} {
  if {[string length $name] > 0} {
    playMsg "Core" "link_already_active_to";
    if [playMsg "LocalAudio" "$name" 0] {
    } else {
      spellWord $name;
    }
  }
}

#
# Executed when the QSO recorder is being activated
#
proc activating_qso_recorder {} {
#  playMsg "Core" "activating";
#  playMsg "Core" "qso_recorder";
}


#
# Executed when the QSO recorder is being deactivated
#
proc deactivating_qso_recorder {} {
#  playMsg "Core" "deactivating";
#  playMsg "Core" "qso_recorder";
}


#
# Executed when trying to deactivate the QSO recorder even though it's
# not active
#
proc qso_recorder_not_active {} {
#  playMsg "Core" "qso_recorder";
#  playMsg "Core" "not_active";
}


#
# Executed when trying to activate the QSO recorder even though it's
# already active
#
proc qso_recorder_already_active {} {
#  playMsg "Core" "qso_recorder";
#  playMsg "Core" "already_active";
}


#
# Executed when the timeout kicks in to activate the QSO recorder
#
proc qso_recorder_timeout_activate {} {
#  playMsg "Core" "timeout"
#  playMsg "Core" "activating";
#  playMsg "Core" "qso_recorder";
}


#
# Executed when the timeout kicks in to deactivate the QSO recorder
#
proc qso_recorder_timeout_deactivate {} {
#  playMsg "Core" "timeout"
#  playMsg "Core" "deactivating";
#  playMsg "Core" "qso_recorder";
}

#
# Executed when the node is being brought online or offline
#
proc logic_online {online} {
  global mycall
  variable CFG_TYPE

  if {$online} {
    playMsg "Core" "online";
    playSilence 250;
    send_short_ident;
  }
}

##############################################################################
#
# Main program
#
##############################################################################

if [info exists CFG_RGR_SOUND_AMP] {
  if {$CFG_RGR_SOUND_AMP != 0} {
    set rgr_sound_amp $CFG_RGR_SOUND_AMP;
  }
}

if [info exists CFG_RGR_SOUND_PITCH] {
  if {$CFG_RGR_SOUND_PITCH > 0} {
    set rgr_sound_pitch $CFG_RGR_SOUND_PITCH;
  }
}

if [info exists CFG_RGR_SOUND_CPM] {
  if {$CFG_RGR_SOUND_CPM > 0} {
    set rgr_sound_cpm $CFG_RGR_SOUND_CPM;
  }
}

if [info exists CFG_RGR_SOUND_TONELENGTH] {
  if {$CFG_RGR_SOUND_TONELENGTH > 0} {
    set rgr_sound_tonelength $CFG_RGR_SOUND_TONELENGTH;
  }
}

if [info exists CFG_RGR_SOUND_RX_ID] {
  if {$CFG_RGR_SOUND_RX_ID > 0} {
    set rgr_sound_rx_id $CFG_RGR_SOUND_RX_ID;
  }
}

if [info exists CFG_CW_FIRST] {
  if {$CFG_CW_FIRST > 0} {
    set cw_first $CFG_CW_FIRST;
  }
}

if [info exists CFG_LONG_VOICE_ID_TIME] {
  if {$CFG_LONG_VOICE_ID_TIME > 0} {
    set long_voice_id_time $CFG_LONG_VOICE_ID_TIME;
  }
}

if [info exists CFG_LONG_VOICE_ID_MODULE] {
  if {$CFG_LONG_VOICE_ID_MODULE > 0} {
    set long_voice_id_module $CFG_LONG_VOICE_ID_MODULE;
  }
}

# end of namespace
}

#
# This file has not been truncated
#
