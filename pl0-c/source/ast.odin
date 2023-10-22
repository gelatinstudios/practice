
package pl0

import "core:fmt"

Consts :: map[Token]int
Vars :: []Token
Procedures :: map[Token]Block

Block :: struct {
    consts: Consts,
    vars: Vars,
    procedures: Procedures,
    statement: Statement,
}

Statement :: union {
    Assignment,
    Call,
    Begin,
    If,
    While,
    Read,
    Write,
}

Assignment :: struct {
    identifier: Token,
    expression: Expression,
}

Call :: struct {
    identifier: Token,
}

Begin :: struct {
    statements: []Statement,
}

If_Or_While :: struct {
    condition: Condition,
    statement: ^Statement,
}

While :: distinct If_Or_While;
If    :: distinct If_Or_While;

Read :: struct {
    identifier: Token
}

Write :: struct {
    expression: Expression
}

Condition :: union {
    Odd,
    Comparison,
}

Odd :: struct {
    expression: Expression,
}

Comparison :: struct {
    left, right: Expression,
    operator: Token,
}

Negation :: struct {
    expression: ^Expression
}

Binary_Op :: struct {
    left, right: ^Expression,
    operator: Token,
}

Number :: struct {
    literal: Token
}

Variable :: struct {
    identifier: Token
}

Expression :: union {
    Negation,
    Binary_Op,
    Number,
    Variable,
}

// printing

print_block :: proc(using block: Block) {
    if len(consts) > 0 {
        fmt.println("consts:")
        for ident, value in consts {
            fmt.printf("    {} = {}\n", ident.raw, value)
        }
    }
    if len(vars) > 0 {
        fmt.println("vars:")
        for var in vars {
            fmt.printf("    {}\n", var.raw)
        }
    }
    if len(procedures) > 0 {
        fmt.println("procs:")
        for ident, block in procedures {
            fmt.println(ident.raw)
            print_block(block)
        }
    }

    print_statement(statement)
}

print_statement :: proc(statement: Statement) {
    switch v in statement {
        case Assignment:
            fmt.printf("{} := ", v.identifier.raw)
            print_expression(v.expression)
            fmt.println()

        case Call:
            fmt.println("call", v.identifier.raw)

        case Begin:
            fmt.println("begin")
            for statement in v.statements do print_statement(statement)
            fmt.println("end")

        case If:
            fmt.print("if ")
            print_condition(v.condition)
            fmt.println(" then ")
            print_statement(v.statement^)

        case While:
            fmt.print("while ")
            print_condition(v.condition)
            fmt.println(" do ")
            print_statement(v.statement^)

        case Read:
            fmt.println("?", v.identifier.raw)

        case Write:
            fmt.print("!")
            print_expression(v.expression)
            fmt.println()
    }
    fmt.println()
}

print_condition :: proc(condition: Condition) {
    switch v in condition {
        case Odd:
            fmt.print("odd ")
            print_expression(v.expression)

        case Comparison:
            print_expression(v.left)
            fmt.printf(" {} ", v.operator.raw)
            print_expression(v.right)
    }
}

print_expression :: proc(expression: Expression) {
    switch v in expression {
        case Negation:
            fmt.print("- ")
            print_expression(v.expression^)

        case Binary_Op:
            print_expression(v.left^)
            fmt.printf(" {} ", v.operator.raw)
            print_expression(v.right^)

        case Number:
            fmt.print(v.literal.raw)
            
        case Variable: 
            fmt.print(v.identifier.raw)
    }
}
