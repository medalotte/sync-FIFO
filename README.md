# sync-FIFO
Description of synchronous FIFO that consist of Dual Port RAM for FPGA implementation by using SystemVerilog

## Feature
- Interface are designed by VALID-READY handshake
- When handshake is established, you can read data with no delay because of logic that prefetch data
- Latency is 3 cycle
- Don't use distributed RAM, but BRAM

## License
MIT
