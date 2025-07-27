# About

Lametta (german for tinsel) is an 8-bit checksum. It's an alternative to simple checksums like arithmetic sum and XOR-sum improving on their characteristics. Like these simple checksums it detects 100% of single byte errors and is high speed. However unlike them it can detect changes in byte order and has strong avalanche effect even for short messages.

Only requiring addition and table lookup makes it suitable for low-level applications like serial protocols and microcontrollers. It's not suited to be used for any cryptographic purposes.

# License

The algorithm and this implementation are placed in public domain.
It's free for use for any purpose but without any warranty.
