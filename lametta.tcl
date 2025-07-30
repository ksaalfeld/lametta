# This software is provided under public domain without any warranty.
# Written 2025 by Klaus Saalfeld

package require Tcl 8.6


namespace eval ::lametta {
   # If file is larger than this threshold it is processed in multiple blocks.
   # Otherwise it's read and processed as a single chunk of data.
   variable FILE_THRES [expr {1024 * 1024}]
   # File block size 
   variable BLOCK_SIZE [expr {64 * 1024}]
   
   namespace export lametta
   namespace ensemble create
}


# Compute Lametta checksum over input string X.
# The result is returned as a decimal number.
# Optionally the seed value can be changed.
#
proc ::lametta::compute {x {seed 0xa5}} {
   set table {
      0x71 0xa3 0x75 0x85 0x5b 0x95 0x94 0x4e
      0x9e 0xe6 0x14 0xcd 0x66 0x8e 0x45 0x7b
      0x53 0x02 0xda 0xdf 0xfb 0x3c 0x8b 0x2f
      0x8d 0x03 0xe9 0x39 0xb4 0xe8 0xf9 0xaa
      0xd5 0x0c 0x7d 0xc7 0x2a 0x2d 0x3f 0x47
      0xe3 0xf3 0x1a 0xa2 0x70 0xd1 0xeb 0xec
      0x04 0x97 0x33 0xcb 0x86 0xf0 0xef 0x21
      0x4b 0x1f 0xd4 0x09 0x5a 0xaf 0x28 0x7a
      0x87 0x16 0xbb 0x13 0xfc 0x00 0xc0 0x25
      0x9b 0x92 0x83 0x6a 0x3b 0x73 0xbd 0x32
      0xdb 0x7c 0xd8 0x6f 0x4a 0x23 0x50 0xe1
      0x57 0x31 0xc1 0xc6 0x5f 0xcc 0x4c 0x4f
      0xe5 0x3a 0xb1 0x11 0xed 0xce 0x10 0x93
      0xdc 0x5d 0x78 0xfa 0x30 0x41 0x8f 0xd6
      0x79 0xbf 0x74 0x07 0x80 0xc8 0x1c 0xf5
      0xdd 0x29 0x1d 0xf2 0x34 0x63 0x24 0x17
      0x77 0xb7 0xae 0x88 0xd2 0x55 0x82 0xe4
      0x3d 0xe2 0xb9 0x9f 0xac 0x89 0xea 0xcf
      0x52 0xf8 0xb5 0x0a 0x6e 0xb8 0x9c 0x49
      0x37 0x98 0x67 0x0b 0xfd 0x2c 0x56 0xf7
      0xa6 0x2e 0xa7 0xd3 0xc4 0x01 0xa9 0xad
      0x08 0xe0 0x60 0xc9 0x26 0xab 0xf6 0xde
      0x22 0x84 0xf4 0x59 0x9a 0xa1 0x68 0x06
      0x51 0x36 0xb3 0xbe 0xb0 0xa5 0x15 0xd7
      0xe7 0x8a 0x0d 0x72 0x5e 0x64 0x9d 0x7e
      0xee 0x19 0x2b 0x81 0xc5 0xbc 0x43 0x99
      0x0e 0x8c 0x1b 0x40 0x6d 0x3e 0x27 0x38
      0xa0 0x05 0xa8 0x1e 0xa4 0x12 0x69 0x54
      0x48 0x96 0xfe 0x90 0xd0 0xd9 0x7f 0x20
      0x58 0xb6 0x0f 0x91 0xf1 0xc3 0xba 0xb2
      0x5c 0x18 0x4d 0xca 0x44 0xc2 0x65 0x35
      0xff 0x46 0x76 0x62 0x6b 0x6c 0x42 0x61
   }
   set y $seed
   # binary scan: returned values are signed int8 and
   # must be translated to unsigned via (x & 0xff) later.
   binary scan $x cu* data
   foreach c $data {
      set y [lindex $table [expr {0xff & ($y + $c)}]]
   }
   return $y
}


# Compute Lametta checksum over string or file.
# Options:
#    -seed <seed>       Set seed value (defaults to 0xA5)
#    -format <fmt>      Specify a format specifier (defaults to "%d" - see Tcl format command)
#    -file <filename>   Compute checksum over contents of specified file.
#                       Without -file option the checksum is computed over
#                       concatenated strings following last option.
#
# Without the -file option all arguments after last option
# are concatenated with spaces to form a single string
# which is then used to compute the checksum.
#
proc ::lametta::lametta {args} {
   array set opts { -seed 0xa5 -file {} -format %d }
   set mode 0
   set optsend 0
   foreach x $args {
      if {$mode == 0} {
         if {$x eq "--"} {
            incr optsend
            break
         }
         if {![string match "-*" $x]} {
            break
         }
         if {![info exists opts($x)]} {
            error "unknown option: $x"
         }
         set key $x
         set mode 1
      } else {
         set opts($key) $x
         set mode 0
      }
      incr optsend
   }
   if {$mode != 0} {
      error "missing value for option $key"
   }
   # Check configuration
   set seed ${opts(-seed)}
   if {![string is integer -strict $seed]} {
      error "bad seed value: must be integer but is $seed"
   }
   set fmt ${opts(-format)}
   if {![string match "%*" $fmt]} {
      error "bad format specifier: $fmt"
   }
   set inputfile ${opts(-file)}
   # Compute checksum
   set y {}
   if {$inputfile eq ""} {
      set N [llength $args]
      if {$optsend >= $N} {
         error "missing string argument(s)"
      }
      # Concat remaining arguments to form a single string
      set msg {}
      set space {}
      while {$optsend < $N} {
         append msg $space [lindex $args $optsend]
         incr optsend
         set space " "
      }
      set y [::lametta::compute $msg $seed]
   } else {
      if {![file exists $inputfile]} {
         error "no such file: $inputfile"
      }
      # If file size is zero the seed is the result
      set y $seed
      set size [file size $inputfile]
      if {$size > 0} {
         set h [::open $inputfile "rb"]
         try {
            fconfigure $h -encoding binary -translation binary -eofchar {}
            # If file size is too big prefer processing in smaller chunks
            variable FILE_THRES
            if {$size > $FILE_THRES} {
               variable BLOCK_SIZE
               while {$size > 0} {
                  set page [expr {$size >= $BLOCK_SIZE ? $BLOCK_SIZE : $size}]
                  set y [::lametta::compute [::read $h $page] $y]
                  incr size -$page
               }
            } else {
               # Process everything in one big block
               set y [::lametta::compute [::read $h] $seed]
            }
         } finally {
            ::close $h
         }
      }
   }
   return [format $fmt $y]
}


package provide lametta 1.0.0
