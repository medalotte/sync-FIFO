/*
 MIT License

 Copyright (c) 2019 Yuya Kudo

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

//-----------------------------------------------------------------------------
// module      : sync_fifo
// description : Synchronous FIFO consist of Dual Port RAM for FPGA implementation
module sync_fifo
  #(parameter
    /*
     You can specify the following parameters.
     1. DATA_WIDTH : input and output data width
     2. FIFO_DEPTH : data capacity
     */
    DATA_WIDTH    = 8,
    FIFO_DEPTH    = 256,
    LB_FIFO_DEPTH = $clog2(FIFO_DEPTH))
   (input logic [DATA_WIDTH-1:0]   in_data,
    input logic                    in_valid,
    output logic                   in_ready,

    output logic [DATA_WIDTH-1:0]  out_data,
    output logic                   out_valid,
    input logic                    out_ready,

    output logic [LB_FIFO_DEPTH:0] count,
    input logic                    clear,

    input logic                    clk,
    input logic                    rstn);

   logic [LB_FIFO_DEPTH-1:0]       in_addr_r, out_addr_r;
   logic [LB_FIFO_DEPTH:0]         count_r;
   logic [DATA_WIDTH-1:0]          mem_din0, mem_din1;
   logic [DATA_WIDTH-1:0]          mem_dout0, mem_dout1;
   logic                           mem_wr_en0, mem_wr_en1;

   logic                           in_exec, out_exec;

   dual_port_RAM #(DATA_WIDTH, FIFO_DEPTH) dp_RAM(.din0(mem_din0),
                                                  .din1(mem_din1),
                                                  .addr0(in_addr_r),
                                                  .addr1(out_addr_r),
                                                  .dout0(mem_dout0),
                                                  .dout1(mem_dout1),
                                                  .wr_en0(mem_wr_en0),
                                                  .wr_en1(mem_wr_en1),
                                                  .clk(clk));

   always_comb begin
      mem_din0   = in_data;
      mem_din1   = 0;
      mem_wr_en0 = 0;
      mem_wr_en1 = 0;

      in_exec  = in_valid & in_ready;
      out_exec = out_valid & out_ready;
   end

endmodule
