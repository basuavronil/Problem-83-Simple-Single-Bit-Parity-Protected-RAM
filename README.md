# Problem-83-Simple-Single-Bit-Parity-Protected-RAM
## How Parity Works in Hardware

In digital electronics, data consists of `0`s and `1`s. Parity generation utilizes a simple mathematical tool: the **XOR Reduction Operator (`^`)**.

When you perform an XOR reduction across all bits of a binary vector, it effectively determines whether the vector contains an **odd** or **even** count of `1`s.

---

**Mathematical Formula**

For an 8-bit input vector `wr_data = 8'b1010_0001` (which contains three `1`s):

`wr_data = 8'b1010_0001` ➔ `Parity Bit = 1 ⊕ 0 ⊕ 1 ⊕ 0 ⊕ 0 ⊕ 0 ⊕ 0 ⊕ 1 = 1`

---

### Logic Rules

| Count of `1`s in Payload | XOR Reduction Result (`^wr_data`) | Even Parity Bit |
| :---: | :---: | :---: |
| **ODD** | `1` | `1` |
| **EVEN** | `0` | `0` |

---

### Verilog Implementation

In Verilog, calculating the parity bit requires a single unary reduction operator:

```verilog
// Unary XOR reduction operator calculates parity across all 8 bits
wire wr_parity = ^wr_data; 
```

### Output 
#### Waveform
<img width="950" height="287" alt="image" src="https://github.com/user-attachments/assets/b436f7ca-c3aa-402e-8e54-885767f428fb" />

#### Simulation Terminal
<img width="795" height="415" alt="image" src="https://github.com/user-attachments/assets/6861c072-45ee-4561-bbd2-2b415796f56a" />

