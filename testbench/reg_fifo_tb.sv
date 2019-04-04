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
// module      : reg_fifo_tb
// description :
module reg_fifo_tb();
   localparam DATA_WIDTH    = 8;
   localparam FIFO_DEPTH    = 4;
   localparam CLK_FREQ      = 100_000_000;
   localparam LB_FIFO_DEPTH = $clog2(FIFO_DEPTH);

   logic [DATA_WIDTH-1:0]  in_data, out_data;
   logic                   in_valid, in_ready, out_valid, out_ready;
   logic [LB_FIFO_DEPTH:0] count;
   logic                   clear;
   logic                   clk, rstn;

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
   // DUT connection
   reg_fifo #(DATA_WIDTH, FIFO_DEPTH) dut(.in_data(in_data),
                                          .in_valid(in_valid),
                                          .in_ready(in_ready),
                                          .out_data(out_data),
                                          .out_valid(out_valid),
                                          .out_ready(out_ready),
                                          .clear(clear),
                                          .count(count),
                                          .clk(clk),
                                          .rstn(rstn));

   //-----------------------------------------------------------------------------
   // test scenario
   logic [DATA_WIDTH-1:0] verification_fifo[$];

   int unsigned           max_data_val = $pow(2, DATA_WIDTH) - 1;
   int unsigned           push_val, pop_val;

   initial begin
      $display("LB_FIFO_DEPTH : %d", LB_FIFO_DEPTH);
      in_data   <= 0;
      in_valid  <= 0;
      out_ready <= 0;
      clear     <= 0;
      rstn      <= 0;

      repeat(100) @(posedge clk);
      rstn <= 1;

      assert(in_ready)
        else $error("in_ready is not initialized : in_ready = %d", in_ready);
      assert(!out_valid)
        else $error("out_valid is not initialized : out_valid = %d", out_valid);
      assert(count == 0)
        else $error("count is not initialized : count = %d", count);

      display_status();
      $display("----- input to FIFO -----");
      for(int i = 0; i < FIFO_DEPTH; i++) begin
         push_val = $urandom_range(0, max_data_val);
         $display("push = %d", push_val);

         // input to verification fifo
         verification_fifo.push_back(push_val);

         // input to DUT
         in_valid <= 1;
         in_data  <= push_val;

         repeat(1) @(posedge clk);
         in_valid <= 0;
      end

      repeat(1) @(posedge clk);
      assert(count == verification_fifo.size())
        else begin
           $display("count is incorrect");
           $display("count: %d", count);
           $display("verification_fifo.size(): %d", verification_fifo.size());
        end
      assert(!in_ready)
        else $error("ready is incorrect when fifo is full");

      display_status();
      $display("----- output from FIFO -----");
      for(int i = 0; i < FIFO_DEPTH; i++) begin
         // output from verification fifo
         pop_val = verification_fifo.pop_front();
         $display("pop = %d", pop_val);

         // output from DUT
         out_ready <= 1;
         repeat(1) @(posedge clk);

         assert(out_data == pop_val)
           else $error("out_data is incorrect : out_data = %d", out_data);
      end

      repeat(1) @(posedge clk);
      display_status();
      $finish;
   end

   function display_status();
      $display("----- FIFO status -----");
      $display("DUT fifo count           = %d", count);
      $display("verification fifo count  = %d", verification_fifo.size());
      foreach(verification_fifo[k]) begin
         $display("verification fifo[%d] = %d", k, verification_fifo[k]);
      end
   endfunction

endmodule
