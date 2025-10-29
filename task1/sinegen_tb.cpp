#include "Vsinegen.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "vbuddy.cpp"

int main(int argc, char **argv, char **env) {
    int i;
    int clk;

    Verilated::commandArgs(argc, argv);

    Vsinegen* sinegen = new Vsinegen;

    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    sinegen->trace(tfp, 99);
    tfp->open("sinegen.vcd");

    if(vbdOpen()!=1) return(-1);
    vbdHeader("Lab 1: Counter");

    sinegen->clk = 1;
    sinegen->rst = 0;
    sinegen->en  = 1;
    sinegen->step = 0;

    for (i = 0; i < 10000000; i++) {
        sinegen->step = vbdValue();

        for (clk = 0; clk < 2; clk++) {
            tfp->dump (2*i + clk);
            sinegen->clk = !sinegen->clk;
            sinegen->eval ();
        }

        vbdPlot(int(sinegen->dout), 0, 255);

        vbdCycle(i+1);

        if (Verilated::gotFinish()|| (vbdGetkey()=='q')) exit(0);
    }

    vbdClose();
    tfp->close();
    exit(0);
}