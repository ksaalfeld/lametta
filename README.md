# About

Lametta (german for tinsel) is an 8-bit checksum. It's an alternative to simple checksums like arithmetic sum and XOR-sum improving on their characteristics. Like these simple checksums it detects 100% of single byte errors and is high speed. However unlike them it can detect changes in byte order and has strong avalanche effect even for short messages.

Only requiring addition and table lookup makes it suitable for low-level applications like serial protocols and microcontrollers. It's NOT suited for cryptographic purpose.

# License

The algorithm and this implementation are placed in public domain.
It's free for use for any purpose but without any warranty.

# Usage

    package require lametta
    
    lametta::lametta -- "Hello world!"  ;# checksum value: 124

The following options are available:

    -file FILE    Compute checksum over contents of specified file
    -seed SEED    Set a new seed value (default: 0xa5)
    -format FMT   Use given format specifier on the result (default: %d)
    --            End of options

# The algorithm

The S-box table T used by the checksum is constructed to contain a permutation of values 0 to 255 (inclusive). Most importantly it fulfills the property:

    T[i] != i for all i

This ensures that 100% of single byte errors get detected.
Apart from that the table was constructed to maximize the cycle length L() for x = 0:

    L(y_{n+1} = T[x + y_{n}]) = 256

This ensures that checksum output gets fully distributed over
value range 0 to 255 for zero byte sequences.
Other optimizations target statistical properties.
