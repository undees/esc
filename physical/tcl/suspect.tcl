#*****************************************************************************#
#                                                                             #
#   Namespace       suspect                                                   #
#                                                                             #
#   Description     Pure Tcl derivative of the expect program control procs.  #
#                                                                             #
#   Usage           # Example 1: Interact dynamically with one program        #
#                   suspect::Import ; # Import commands into the global NS.   #
#                   set channel [Spawn program args] ; # Open a cmd pipeline. #
#                   set pid [CVar $channel pid] ; # Get the pid of the prog.  #
#                   Expect $channel ?options? switchBlock ; # Wait 4 strings. #
#                   set data [CVar $channel received] ; # Get all until match.#
#                   Send $channel "Do this\r" ; # Send a command.             #
#                   ... ; # Repeat as many times as necessary.                #
#                   Close $channel ; # Close the pipeline and free variables. #
#                                                                             #
#                   # Example 2: Run several programs in parallel and wait    #
#                   #  for their completion (in any order)                    #
#                   proc OnProgramExit {channel} { # Callback run on pgm exit #
#                     set output [CVar $channel received] ; # Program output  #
#                     set exitCode [CVar $channel exitCode] ; # Pgm exit code #
#                     Close $channel ; # Close the pipeline and free vars.    #
#                   }                                                         #
#                   suspect::Import ; # Import commands into the global NS.   #
#                   set channels {} ; # List of open command pipelines        #
#                   lappend channels [Spawn program1 args] ; # Start program1 #
#                   ...                                                       #
#                   lappend channels [Spawn programN args] ; # Start programN #
#                   WaitForAll $channels -onEOF OnProgramExit ; # Wait 4 exit #
#                                                                             #
#   Notes           The routines are not compatible with expect, in an        #
#                   attempt to fix some of expect's shortcomings:             #
#                   - expect uses global variables, which makes it difficult  #
#                     to interact with several pipelines at the same time.    #
#                     All suspect functions use a pipeline handle, and store  #
#                     data in pipeline-specific namespace variables.          #
#                   - I've been bitten by some powerful, but dangerous,       #
#                     options of the expect routine. These were disabled      #
#                     here. See the Expect routine header below for details.  #
#                                                                             #
#                   Known issues:                                             #
#                   - Expect will fail (actually time-out) if the pipelined   #
#                     program does not flush its prompt output. (Even if that #
#                     program does work fine when invoked in the shell.)      #
#                   - It will also fail with programs that require a pseudo-  #
#                     tty to send a prompt. (One of the big superiorities of  #
#                     the real expect!)                                       #
#                                                                             #
#   History                                                                   #
#    2003/03    ST  Sample code written by Stephen Trier and placed in the    #
#                   public domain. See: http://wiki.tcl.tk/8531               #
#    2009/06/18 JFL Created these routines, loosely based on ST's sample code.#
#    2009/07/09 JFL Added routine WaitForAll, to do parallel waits.           #
#                                                                             #
#*****************************************************************************#

namespace eval suspect {
  variable timeout 10 ; # Default timeout, in seconds. 0 = No timeout.

# Define a public procedure, exported from this namespace
proc xproc {name args body} {
  namespace export $name
  proc $name $args $body
  variable xprocs ; # List of all procedures exported from this namespace.
  lappend xprocs $name
}

# Import all public procedures from this namespace into the caller's namespace.
proc Import {{pattern *}} {
  namespace eval [uplevel 1 namespace current] \
    "namespace import -force [namespace current]::$pattern"
  # Duplicate Tcl execution trace operations, if any.
  variable xprocs ; # List of all procedures exported from this namespace.
  catch { # This will fail in Tcl <= 8.3
    foreach proc $xprocs {
      foreach trace [trace info execution [namespace current]::$proc] {
        foreach {ops cmd} $trace break
        uplevel 1 [list trace add execution $proc $ops $cmd]
      }
    }
  }
}

# Remove an argument from the head of a routine argument list.
proc PopArg {{name args}} {
  upvar 1 $name args
  set arg [lindex $args 0]              ; # Extract the first list element.
  set args [lrange $args 1 end]         ; # Remove the first list element.
  return $arg
}

# Get the error code returned by an external program
proc ErrorCode {{err -1}} { # err = The TCL error caught when executing the program
  if {$err != 0} { # $::errorCode is only meaningful if we just had an error.
    switch -- [lindex $::errorCode 0] {
      "NONE" { # The exit code _was_ 0, only pollution on stderr.
        return 0
      }
      "CHILDSTATUS" { # Non-0 exit code.
        return [lindex $::errorCode 2]
      }
      "POSIX" { # Program failed to start, or was killed.
        return -1
      }
    }
  }
  return $err
}

# Get/Set a channel-specific variable
xproc CVar {channel var args} {
  variable $channel
  if {"$args" == ""} {
    set ${channel}($var)
  } else {
    set ${channel}($var) [join $args ""]
  }
}
proc CAppend {channel var args} {
  variable $channel
  append ${channel}($var) [join $args ""]
}

# Open a command pipeline
xproc Spawn {args} {
  if {"$args" == ""} {
    error "Spawn: No command specified"
  }
  set channel [open "|$args" RDWR]
  set msStart [clock clicks -milliseconds]
  CVar $channel msStart $msStart ; # Record the startup time
  CVar $channel msStop $msStart  ; # Make sure it's defined (In case of timeout)
  fconfigure $channel -blocking 0 -buffering none
  set ns [namespace current]
  fileevent $channel readable "${ns}::TriggerEvent $channel readable 1"
#  fileevent $channel writable "${ns}::TriggerEvent $channel writable 1"
  CVar $channel cmd $args ; # Record the command line for future diagnostics.
  CVar $channel pid [pid $channel] ; # Record the pipeline pid
  return $channel
}

# Send data to the command pipeline.
xproc Send {channel string} {
  puts -nonewline $channel $string
  # flush $channel ; # Useful only in buffering line mode
}

# Manage pipe I/O events
proc TriggerEvent {channel event {value 1}} {
  CVar $channel $event $value ; # Set the channel-specific event variable
  variable events
  lappend events [list $channel $event $value] ; # Useful for parallel waits
}
proc WaitEvent {channel event} {
  vwait [namespace current]::${channel}($event)
  CVar $channel $event
}

# Read from channel, with an optional timeout. Event driven, using vwait.
proc Read {channel args} { # Usage: Read channel [N]
  set readCmd [linsert $args 0 read $channel] ; # The read command
  set readable [WaitEvent $channel readable]
  if {!$readable} {
    error TIMEOUT
  }
  if [eof $channel] {
    CVar $channel msStop [clock clicks -milliseconds]
    error EOF
  }
  set data [eval $readCmd] ; # Read the requested data.
  return $data
}

#-----------------------------------------------------------------------------#
#                                                                             #
#   Function        Expect                                                    #
#                                                                             #
#   Description     Pure Tcl derivative of the expect command                 #
#                                                                             #
#   Parameters      channel            R/W channel to a command pipeline      #
#                   OPTIONS            See the options list below             #
#                   switchBlock        The various alternatives and action    #
#                                                                             #
#   Options         -exact             Use exact strings matching (default)   #
#                   -glob              Use glob-style matching                #
#                   -regexp            Use regular expressions matching       #
#                   -timeout N         Timeout after N seconds. Default: 10   #
#                   -onTIMEOUT BLOCK   What to do in case of timeout          #
#                   -onEOF BLOCK       What to do in case of End Of File      #
#                                                                             #
#   Returns         User defined. By default: Nothing if found, or errors out #
#                   in case of EOF or TIMEOUT.                                #
#                                                                             #
#   Notes           This routine is incompatible with the real expect on      #
#                   purpose, to fix some of its shortcomings:                 #
#                   - expect's ability to specify either one switch block, or #
#                     multiple block items (Like Tcl's own exec), is nice in  #
#                     simple cases, but always backfires when the program     #
#                     complexity grows. suspect::Expect requires one block.   #
#                   - I've been bitten by expect's inability to expect the    #
#                     word timeout. (I found the workaround, but too late.)   #
#                     suspect::Expect handles EOF and TIMEOUT in options only.#
#                   - expect allows options within the switch block. Very     #
#                     powerful to use distinct search criteria for distinct   #
#                     strings. But at the cost of making these very options   #
#                     difficult to be themselves expected. suspect::Expect    #
#                     only allows options before the switch block.            #
#                                                                             #
#                   Things like exp_continue are not yet supported.           #
#                                                                             #
#   History                                                                   #
#    2009/06/18 JFL Created these routines, loosely based on ST's sample code.#
#                                                                             #
#-----------------------------------------------------------------------------#

xproc Expect {channel args} { # Usage: Expect channel [options] switchBlock
  # Namespace variables
  variable timeout
  # Local variables
  set sMode -exact ; # Switch mode. One of: -exact -glob -regexp
  set msTimeout [expr 1000 * $timeout] ; # Timeout, in milli-seconds
  set onEof "error {Expect: EOF reading from command pipeline $channel :\
             [CVar $channel cmd]}" ; # What to do in case of end of file
  set onTimeout "error {Expect: TIMEOUT waiting for command pipeline $channel :\
                 [CVar $channel cmd]}" ; # What to do in case of timeout

  # Separate the last switch block from the options
  if {"$args" == ""} {
    error "Expect: No switch block defined."
  }
  set expectBlock [lindex $args end]
  set args [lrange $args 0 end-1]

  # Process the options
  while {"$args" != ""} {
    set opt [PopArg]
    switch -- $opt {
      "-exact" - "-glob" - "-regexp" {
        set sMode $opt
      }
      "-onEOF" - "eof" {
        set onEof [PopArg]
      }
      "-onTIMEOUT" - "timeout" {
        set onTimeout [PopArg]
      }
      "-timeout" {
        set msTimeout [expr [PopArg] * 1000]
      }
      default {
        error "Expect: Unsupported option $opt"
      }
    }
  }

  # Build the switch statement we will use for matching
  set switchBlock {}
  foreach {match script} $expectBlock {
    set match0 $match
    set before {}
    set after {}
    switch -- $sMode {
      -exact {
        set before {***=}
      }
      -glob {
        if {[string index $match 0] eq "^"} {
          set match [string range $match 1 end]
        } else {
          set before *
        }
        if {[string index $match end] eq "\$"} {
          set match [string range $match 0 end-1]
        } else {
          set after *
        }
      }
    }
    lappend switchBlock $before$match$after
    lappend switchBlock "
      after cancel \$idTimeout
      set channelVar(match) [list $match0] ;
      return \[uplevel 1 [list $script]\]"
  }
  if {"$sMode" == "-exact"} {
    set sMode -regexp
  }

  # Manage optional timeouts
  set idTimeout "" ; # "after cancel $idTimeout" will silently ignore this id.
  set ns [namespace current]
  if {$msTimeout} {
    set idTimeout [after $msTimeout "${ns}::TriggerEvent $channel readable 0"]
  }

  # Gather characters from the channel and run them through our new switch statement.
  CVar $channel received ""
  while {1} {
    if [catch {set c [Read $channel 1]} errMsg] {
      switch -- $errMsg {
        "TIMEOUT" {
          return [uplevel 1 $onTimeout]
        }
        "EOF" {
          after cancel $idTimeout
          return [uplevel 1 $onEof]
        }
        default {
          error "Error reading $channel: $errMsg"
        }
      }
    }
    CAppend $channel received $c
    switch $sMode -- [CVar $channel received] $switchBlock
  }
}

# Common case where we expect a single exact string
xproc ExpectString {channel string} {
  Expect $channel [list $string]
}

# Close a command pipeline, and return the program exit code.
xproc CloseCommand {channel} {
  variable $channel
  if [info exists ${channel}(exitCode)] {
    return [CVar $channel exitCode]
  }
  fconfigure $channel -blocking 1 ; # Make sure close checks for the exit code
  set err [catch {close $channel} errMsg] ; # Get the Tcl error code
  set err [ErrorCode $err] ; # Get the command exit code
  CVar $channel exitCode $err
  return $err
}

# Close a command pipeline, and free all local resources. Return the exit code.
xproc Close {channel} {
  variable $channel
  set err 0
  if [info exists $channel] {
    set err [CloseCommand $channel] ; # Get the command exit code
    unset $channel
  }
  return $err
}

#-----------------------------------------------------------------------------#
#                                                                             #
#   Function        WaitForAll                                                #
#                                                                             #
#   Description     Wait for the completion of several parallel programs      #
#                                                                             #
#   Parameters      channels           List of spawned tasks                  #
#                   -onEOF proc        Call $proc $channel after each EOF.    #
#                                                                             #
#   Returns         Nothing, or errors out in case of TIMEOUT.                #
#                                                                             #
#   Notes           Timeout out not implemented yet.                          #
#                                                                             #
#   History                                                                   #
#    2009/07/09 JFL Created this routine.                                     #
#    2009/09/28 JFL Added the -onEOF option.                                  #
#                                                                             #
#-----------------------------------------------------------------------------#

xproc WaitForAll {channels args} {
  variable events
  set onEOF ""
  # Process the options
  while {"$args" != ""} {
    set opt [PopArg]
    switch -- $opt {
      "-onEOF" - "eof" {
        set onEOF [PopArg]
      }
      default {
        error "WaitForAll: Unsupported option $opt"
      }
    }
  }
  # Wait for the EOF on all channels
  set nLeft [llength $channels]
  foreach channel $channels {
    # fconfigure $channel -buffering full ; # Minimize the # of read events.
  }
  while {$nLeft} {
    vwait [namespace current]::events
    foreach event $events {
      foreach {channel event value} $event break
      if {("$event" != "readable") || ($value != 1)} continue
      set input [read $channel]
      CAppend $channel received $input
      if {[eof $channel] && ([set ix [lsearch $channels $channel]] != -1)} {
        CVar $channel msStop [clock clicks -milliseconds]
        set channels [lreplace $channels $ix $ix]
        incr nLeft -1
        if {"$onEOF" != ""} {
          eval $onEOF $channel
        }
      }
    }
    set events {}
  }
}

} ; # End of namespace suspect
