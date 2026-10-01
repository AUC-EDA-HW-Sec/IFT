# Import Yosys commands into the Tcl namespace
yosys -import

if { $argc == 0 } {
    puts "Error: No module name passed to synthesis script."
    exit 1
}

set TOP [lindex $argv 0]

proc lut_param_from_rows {rows input_count} {
    set bits [lrepeat 16 0]

    foreach row $rows {
        set fields [split [string trim $row]]
        if {[llength $fields] < 2 || [lindex $fields 1] ne "1"} {
            continue
        }

        set indices {0}
        set pattern [lindex $fields 0]
        for {set bit 0} {$bit < 4} {incr bit} {
            if {$bit < $input_count} {
                set value [string index $pattern $bit]
            } else {
                set value "-"
            }

            set next_indices {}
            foreach index $indices {
                if {$value eq "-" || $value eq "0"} {
                    lappend next_indices $index
                }
                if {$value eq "-" || $value eq "1"} {
                    lappend next_indices [expr {$index | (1 << $bit)}]
                }
            }
            set indices $next_indices
        }

        foreach index $indices {
            lset bits $index 1
        }
    }

    return [join [lreverse $bits] ""]
}

proc convert_blif_luts {file_name} {
    set input_file [open $file_name r]
    set lines [split [read $input_file] "\n"]
    close $input_file

    set converted {}
    set line_index 0
    while {$line_index < [llength $lines]} {
        set line [lindex $lines $line_index]
        set fields [split [string trim $line]]

        if {[llength $fields] > 1 && [lindex $fields 0] eq ".names" && [llength $fields] > 2} {
            set input_names [lrange $fields 1 end-1]
            set output_name [lindex $fields end]
            set rows {}
            incr line_index

            while {$line_index < [llength $lines]} {
                set row [lindex $lines $line_index]
                if {[string match ".*" [string trim $row]]} {
                    break
                }
                if {[string trim $row] ne ""} {
                    lappend rows $row
                }
                incr line_index
            }

            set connections {}
            set input_index 0
            foreach input_name $input_names {
                lappend connections "in${input_index}=${input_name}"
                incr input_index
            }
            while {$input_index < 4} {
                lappend connections "in${input_index}=\$false"
                incr input_index
            }
            lappend converted ".subckt lut4 [join $connections { }] out=${output_name}"
            lappend converted ".param LUT [lut_param_from_rows $rows [llength $input_names]]"
            continue
        }

        lappend converted $line
        incr line_index
    }

    set output_file [open $file_name w]
    set output_text [join $converted "\n"]
    puts -nonewline $output_file "${output_text}\n"
    close $output_file
}

proc run_synth { module_name } {
    puts "========================================"
    puts " Running synthesis for: ${module_name}"
    puts "========================================"

    file mkdir ./${module_name}/outputs/eblif

    # Load RTL
    read_verilog ./${module_name}/rtl/${module_name}.v

    setattr -set keep_hierarchy 1
    synth -top ${module_name}

    # 'procs' replaces Yosys 'proc' in Tcl to prevent keyword collision
    procs; opt; fsm; opt; memory; opt

    # Map to 4-LUTs
    abc -lut 4
    opt_clean

    # Rename signals
    autoname

    # Output BLIF
    set output_file ./${module_name}/outputs/eblif/${module_name}.eblif
    write_blif -param -conn $output_file
    convert_blif_luts $output_file
}

run_synth $TOP
