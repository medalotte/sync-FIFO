# SystemVerilog-sync-FIFO
Description of synchronous FIFO that consist of Dual Port RAM for FPGA implementation by using SystemVerilog

## Feature
- Interface are designed by VALID-READY handshake
- You can read data with no delay because of data prefetch logic when handshake is established
- Latency is 3 cycle
- Don't use distributed RAM, but BRAM

## License
MIT
