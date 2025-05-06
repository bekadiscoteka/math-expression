# Pipelined Arithmetic Expression Solver in Verilog

**Author:** Yerman Bekzat  
**Date:** 06.05.2025  
**Email:** [yermanbekzat@gmail.com](mailto:yermanbekzat@gmail.com)  
**Telegram:** [@viaBeka](https://t.me/viaBeka)

---

## Overview

This project implements a high-performance, pipelined arithmetic expression solver in Verilog. It features parameterized bit-width support and UART communication for hardware validation. Designed for FPGA usage, the system enables continuous input with minimized latency and synchronized output.

---

## Project Structure

- **`src/`** – Contains all HDL files including the main design and testbenches.
  - `design.v` – Core pipelined arithmetic solver.
  - `design_tb.v` – Testbench for verifying the main design.
  - `design_test.do` – TCL script to run simulation in ModelSim.
  - `top.v` – Top module to interface `design.v` with UART and 7-segment display.
  - `script.py` – Python script for interacting with FPGA via UART and validating results.
- **`Digital Scheme Graphic.pdf`** – Diagram showing pipelining structure and bit-width management.
- **`Performance + resource report.docx`** – Documentation and technical report.

---

## Key Features

- **Pipelined Design:**  
  Three-stage pipeline enables one-cycle input throughput without waiting for the result.

- **Parameterization:**  
  Configurable bit width using parameter `W` for flexible operand sizing.

- **Latency Optimization:**  
  Optimized for speed and performance with minimal latency.

- **Input/Output Control:**  
  - Inputs are submitted when `start` signal is high.
  - Output is valid only when `valid` signal is asserted for one cycle.

- **Bit Overflow Handling:**  
  Each pipeline stage adjusts bit widths to safely handle overflow conditions.

- **Simulation & Verification:**  
  Run the ModelSim simulation with:
  ```sh
  vsim -do design_test.do
  ```

- **FPGA Interaction & Testing:**  
  `script.py` sends signed integer operands via UART to the FPGA. The hardware calculates the result using `design.v`, returns the output, and the script compares it against a reference software result.

---

## Demo

📺 **Video Demo:** [Watch on YouTube](https://youtu.be/6_MFEHwTwNE)

This video demonstrates the interaction between the Python script and the FPGA-based hardware module.

---

## Contact

For any questions, feel free to reach out via email or Telegram.
