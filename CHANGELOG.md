Modified coprocessor:

- Exception Bus is unmangled
- *cpu_mode* is now called *user_mode* (see: [MIPS v3])

Added default kernel:

- Loads *main*
- Verbose exceptions

Modified build script:

- Selection of kernel (-k|--kernel)
- Bare-metal mode, load program without kernel (-b|--bare)

Added exceptions:

- Address range for load/store (access to IO only from kernel mode)
- Trap (launched after MAX_CYCLES cycles)

[MIPS v3]: http://www.cs.cornell.edu/courses/cs3410/2015sp/MIPS_Vol3.pdf
