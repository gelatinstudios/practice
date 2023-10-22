
package pl0

import "core:unicode"
import "core:unicode/utf8"
import "core:strings"
import "core:strconv"

Tokenizer :: struct {
    source: string,
    at: int,
    w: int, // 
}

Token_Kind :: enum {
    Identifier,
    Punctuation,
    Number,
}

Token :: struct {
    raw: string,
    at: int,
    kind: Token_Kind,
    value: int,
}

peek_rune :: proc(using t: ^Tokenizer) -> rune {
    r, width := utf8.decode_rune_in_string(source[at:])
    t.w = width
    return r
}

advance_rune :: proc(using t: ^Tokenizer) {
    at += w
}

get_rune :: proc(using t: ^Tokenizer) -> rune {
    r := peek_rune(t)
    advance_rune(t)
    return r
}

advance_whitespace :: proc(using t: ^Tokenizer) {
    for unicode.is_white_space(peek_rune(t)) {
        advance_rune(t)
    }
}

get_token :: proc(using t: ^Tokenizer) -> (Token, bool) {
    if at >= len(source) do return {}, false

    advance_whitespace(t)
    defer advance_whitespace(t)
    
    result: Token
    result.at = at
    
    r := get_rune(t)

    if r == '_' || unicode.is_letter(r) {
        result.kind = .Identifier
        
        r := peek_rune(t)
        for r == '_' || unicode.is_letter(r) || unicode.is_digit(r) {
            advance_rune(t)
            r = peek_rune(t)
        }
    } else if unicode.is_digit(r) {
        result.kind = .Number

        r := peek_rune(t)
        for unicode.is_digit(r) {
            advance_rune(t)
            r = peek_rune(t)
        }
    } else {
        result.kind = .Punctuation

        if strings.contains_rune("<>:", r) && peek_rune(t) == '=' {
            advance_rune(t)
        }
    }
    
    result.raw = source[result.at:at]

    if result.kind == .Number {
        value, ok := strconv.parse_int(result.raw)
        if !ok {
            panic("couldn't parse int")
        }
        result.value = value
    }
    
    return result, true
}

peek_token :: proc(tokenizer: ^Tokenizer) -> (Token, bool) {
    tmp := tokenizer^
    return get_token(&tmp)
}

expect_token :: proc(tokenizer: ^Tokenizer, expected: string) {
    t, ok := get_token(tokenizer)
    assert(ok)
    assert(t.raw == expected)
}

peek_is_token :: proc(tokenizer: ^Tokenizer, ident: string) -> bool {
    t, ok := peek_token(tokenizer)
    return ok && t.raw == ident
}

is_token :: proc(token: Token, raw: string) -> bool {
    return token.raw == raw
}

advance_token :: proc(tokenizer: ^Tokenizer) {
    get_token(tokenizer)
}

precedences := map[string]int {
    "+" = 1,
    "-" = 1,
    "*" = 2,
    "/" = 2,
}

is_bin_op :: proc(token: Token) -> bool {
    return token.raw in precedences
}
