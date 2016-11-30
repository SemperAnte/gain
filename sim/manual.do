transcript on

if {[file exists rtl_work]} {
   vdel -lib rtl_work -all
}

vlib rtl_work
vmap work rtl_work

vlog     -work work {../rtl/gainAvs.sv}
vlog     -work work {../rtl/gainMult.sv}
vlog     -work work {../rtl/gain.sv}
vlog     -work work {tb_gain.sv}

vsim -t 1ns -L work -voptargs="+acc" tb_gain

add wave *

view structure
view signals
run 300 us
wave zoomfull