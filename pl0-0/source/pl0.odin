
package pl0

import "core:os"

main :: proc() {
    source, ok := os.read_entire_file(os.args[1])
    assert(ok)
    
    tokenizer := Tokenizer {}
    tokenizer.source = string(source)

    parser: Parser
    parser.tokenizer = &tokenizer
    
    program := parse(&parser)
    codegen(parser.symbol_table, program)
}
