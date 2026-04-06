**Baseline Configuration:** Profiled using a standard CPU with an input tensor shape of (1, 3, 224, 224) (Batch Size: 1).
| Layer Name | Output Shape | Parameters | MACs (Mult-Adds) |
| :--- | :--- | :--- | :--- |
| **Conv2d: 1-1** | [1, 64, 112, 112] | 9,408 | 118,013,952 |
| **Conv2d: 3-1** | [1, 64, 56, 56] | 36,864 | 115,605,504 |
| **Conv2d: 3-4** | [1, 64, 56, 56] | 36,864 | 115,605,504 |
| **Conv2d: 3-7** | [1, 64, 56, 56] | 36,864 | 115,605,504 |
| **Conv2d: 3-10** | [1, 64, 56, 56] | 36,864 | 115,605,504 |

*Note: Layers 3-16, 3-20, 3-23, 3-26, 3-29, 3-33, 3-36, 3-39, 3-42, 3-46, and 3-49 were also tied for 2nd place with 115,605,504 MACs.*

### Arithmetic Intensity for Conv2d: 1-1
* **Total MACs:** 118,013,952
* **Total FLOPs:** 2 x 118,013,952 = 236,027,904 FLOPs

**Memory Traffic (Bytes):**
* **Weights:** 9,408 parameters x 4 bytes = 37,632 bytes
* **Input Activations:** 1 x 3 x 224 x 224 = 150,528 elements x 4 bytes = 602,112 bytes
* **Output Activations:** 1 x 64 x 112 x 112 = 802,816 elements x 4 bytes = 3,211,264 bytes
* **Total Memory Traffic:** 37,632 + 602,112 + 3,211,264 = 3,851,008 bytes

**Arithmetic Intensity:**
AI = Total FLOPs / Total Bytes
AI = 236,027,904 / 3,851,008 = 61.29 FLOPs/byte
