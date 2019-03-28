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
// module      : dual_port_RAM_tb
// description :
module dual_port_RAM_tb();
   localparam DATA_WIDTH    = 8;
   localparam RAM_DEPTH     = 256;
   localparam CLK_FREQ      = 100_000_000;
   localparam LB_RAM_DEPTH = $clog2(RAM_DEPTH);

   logic [DATA_WIDTH-1:0]   din0, din1;
   logic [LB_RAM_DEPTH-1:0] addr0, addr1;
   logic [DATA_WIDTH-1:0]   dout0, dout1;
   logic                    wr_en0, wr_en1;
   logic                    clk;

   //-----------------------------------------------------------------------------
   // clock generater
   localparam CLK_PERIOD = 1_000_000_000 / CLK_FREQ;

   initial begin
      clk = 1'b0;
   end

   always #(CLK_PERIOD / 2) begin
      clk = ~clk;
   end

   //-----------------------------------------------------------------------------
   // DUT
   dual_port_RAM #(DATA_WIDTH, RAM_DEPTH) dut(.din0(din0),
                                              .din1(din1),
                                              .addr0(addr0),
                                              .addr1(addr1),
                                              .dout0(dout0),
                                              .dout1(dout1),
                                              .wr_en0(wr_en0),
                                              .wr_en1(wr_en1),
                                              .clk(clk));

   //-----------------------------------------------------------------------------
   // test scenario
   logic [RAM_DEPTH-1:0][DATA_WIDTH-1:0] verification_ram = '{default:0};
   int unsigned                          max_data_val = $pow(2, DATA_WIDTH) - 1;
   int unsigned                          val;

   initial begin
      for(int i = 0; i < RAM_DEPTH; i++) begin
         val = $urandom_range(0, max_data_val);

         // input to verification ram
         verification_ram[i] = val;

         // input to dut
         addr0  <= i;
         din0   <= val;
         wr_en0 <= 1;
         if(1 < i) begin
            addr1  <= i - 1;
            wr_en1 <= 0;
         end

         repeat(1) @(posedge clk);
         wr_en0 <= 0;

         if(1 < i) begin
            assert(dout1 == verification_ram[i - 2])
              else $error("dout is incorrect : %d", dout1);
         end
      end

      for(int i = 0; i < RAM_DEPTH; i++) begin
         val = verification_ram[i];
         // output from dut
         addr0  <= i;
         wr_en0 <= 0;

         // 1cycle delay
         repeat(1) @(posedge clk);

         repeat(1) @(posedge clk);
         assert(dout0 == val)
           else $error("dout is incorrect : %d", dout0);
      end

      $finish;
   end

endmodule
