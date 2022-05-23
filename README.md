# L7-packet-parsing

A CRG (Counting Regular Grammar) based field extractor implementation.

The tool consists of these modules:

- generator: generates the parser, implemented by Python
    - frontend: reads the CCFG specification, generates the intermediates as a set of Rule objects
    - regularizer: reads the rules, generates the CRG
    - backend: generates C++ code of the parser
- runtime: the routines and primitives used by the generated parser, in C++ binaries