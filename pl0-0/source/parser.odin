
package pl0

Parser :: struct {
    tokenizer: ^Tokenizer,
    using symbol_table: Symbol_Table,
}

Symbol_Table :: struct {
    all_consts: Consts,
    all_vars: [dynamic]Token,
    all_procedures: map[Token]Block
}

parse_consts :: proc(using parser: ^Parser) -> Consts {
    result := make(Consts)
    if peek_is_token(tokenizer, "const") {
        advance_token(tokenizer)
        for {
            ident, ok := get_token(tokenizer)
            assert(ok)
            
            expect_token(tokenizer, "=")

            number, number_ok := get_token(tokenizer)
            assert(number_ok)
            assert(number.kind == .Number)

            result[ident] = number.value
            all_consts[ident] = number.value

            tok, tok_ok := get_token(tokenizer)
            assert(tok_ok)
            if tok.raw == "," do continue
            if tok.raw == ";" do break

            panic("unexpected token!!")
        }
    }
    return result
}

parse_vars :: proc(using parser: ^Parser) -> []Token {
    result := make([dynamic]Token)
    if peek_is_token(tokenizer, "var") {
        advance_token(tokenizer)
        for {
            ident, ok := get_token(tokenizer)
            assert(ok)

            append(&all_vars, ident)
            append(&result, ident)
            
            tok, tok_ok := get_token(tokenizer)
            assert(tok_ok)
            if tok.raw == "," do continue
            if tok.raw == ";" do break

            panic("unexpected token!!")
        }
    }
    return result[:]
}

parse_procedures :: proc(using parser: ^Parser) -> Procedures {
    result := make(Procedures)
    for {
        if !peek_is_token(tokenizer, "procedure") do break
        advance_token(tokenizer)

        ident, ident_ok := get_token(tokenizer)
        assert(ident_ok)

        expect_token(tokenizer, ";")

        block := parse_block(parser)

        expect_token(tokenizer, ";")

        result[ident] = block
        all_procedures[ident] = block
    }
    return result
}

parse_block :: proc(using parser: ^Parser) -> Block {
    result: Block

    result.consts = parse_consts(parser)
    result.vars = parse_vars(parser)
    result.procedures = parse_procedures(parser)
    result.statement = parse_statement(parser)
    
    return result
}

// starts after the `if` or `while` keyword
parse_if_or_while :: proc(using parser: ^Parser, sep: string) -> If_Or_While {
    result: If_Or_While
    result.condition = parse_condition(parser)
    expect_token(tokenizer, sep)
    result.statement = new_clone(parse_statement(parser))
    return result
}

parse_condition :: proc(using parser: ^Parser) -> Condition {
    if peek_is_token(tokenizer, "odd") {
        advance_token(tokenizer)
        return Odd {parse_expression(parser)}
    }

    result: Comparison
    result.left = parse_expression(parser)
    result.operator, _ = get_token(tokenizer)
    assert(result.operator.kind == .Punctuation)
    result.right = parse_expression(parser)
    return result
}

parse_expression :: proc(using parser: ^Parser) -> Expression {
    parse_primary :: proc(using parser: ^Parser) -> Expression {
        tok, ok := get_token(tokenizer)
        assert(ok)

        switch tok.raw {
            case "(":
                result := parse_expression(parser)
                expect_token(tokenizer, ")")
                return result

            case "-": return Negation{new_clone(parse_primary(parser))}
            case "+": return parse_primary(parser)

            case:
                if tok.kind == .Identifier {
                    return Variable{tok}
                } else if tok.kind == .Number {
                    return Number{tok}
                } else {
                    unreachable()
                }
        }
    }

    parse_subexpression :: proc(using parser: ^Parser, left: Expression, min_precedence: int) -> Expression {
        left := left
        lookahead, ok := peek_token(tokenizer)
        assert(ok)

        for is_bin_op(lookahead) && precedences[lookahead.raw] >= min_precedence {
            op := lookahead
            advance_token(tokenizer)
            op_prec := precedences[op.raw]
            right := parse_primary(parser)
            lookahead, _ = peek_token(tokenizer)
            for is_bin_op(lookahead) && precedences[lookahead.raw] > op_prec {
                right = parse_subexpression(parser, right, op_prec + 1)
                lookahead, _ = peek_token(tokenizer)
            }
            left = Binary_Op {
                left = new_clone(left),
                right = new_clone(right),
                operator = op,
            }
        }

        return left
    }
    
    return parse_subexpression(parser, parse_primary(parser), 0)
}

parse_statement :: proc(using parser: ^Parser) -> Statement {
    token, ok := get_token(tokenizer)
    assert(ok)
    switch token.raw {
        case "call":
            token , ok:= get_token(tokenizer)
            assert(ok)
            return Call {token}

        case "begin":
            statements := make([dynamic]Statement)
            append(&statements, parse_statement(parser))
            for {
                token, ok = get_token(tokenizer)
                assert(ok)

                if token.raw == "end" do break

                assert(token.raw == ";")

                append(&statements, parse_statement(parser))
            }
            return Begin {statements[:]}

        case "if":
            return If(parse_if_or_while(parser, "then"))
                
        case "while":
            return While(parse_if_or_while(parser, "do"))

        case "read": fallthrough
        case "?":
            token, ok := get_token(tokenizer)
            assert(ok)
            return Read{token}

        case "write": fallthrough
        case "!":
            return Write{parse_expression(parser)}

        case:
            assert(token.kind == .Identifier)
            expect_token(tokenizer, ":=")
            expression := parse_expression(parser)

            return Assignment {
                identifier = token,
                expression = expression,
            }
    }
    unreachable()
}

parse :: proc(using parser: ^Parser) -> Block {
    result := parse_block(parser)
    expect_token(tokenizer, ".")
    return result
}
