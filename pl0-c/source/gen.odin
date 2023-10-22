
package pl0

import "core:fmt"

gen_condition :: proc(condition: Condition) {
    switch v in condition {
        case Odd:
            fmt.print("(")
            gen_expression(v.expression)
            fmt.print(") % 2 != 0")

        case Comparison:
            fmt.print("(")
            gen_expression(v.left)
            fmt.print(") ")
            op := v.operator.raw
            switch op {
                case "=": fmt.print("==")
                case "#": fmt.print("!=")
                    
                case "<":  fmt.print(op)
                case "<=": fmt.print(op)
                case ">":  fmt.print(op)
                case ">=": fmt.print(op)

                case: unreachable()
            }
            fmt.print(" (")
            gen_expression(v.right)
            fmt.print(")")
    }
}

gen_expression :: proc(expression: Expression) {
    switch v in expression {
        case Negation:
            fmt.print("-(")
            gen_expression(v.expression^)
            fmt.print(")")

        case Binary_Op:
            fmt.print("(")
            gen_expression(v.left^)
            fmt.print(") ")
            fmt.print(v.operator.raw)
            fmt.print(" (")
            gen_expression(v.right^)
            fmt.print(")")

        case Number:
            fmt.print(v.literal.raw)

        case Variable:
            fmt.print(v.identifier.raw)
    }
}

gen_statement :: proc(statement: Statement) {
    switch v in statement {
        case Assignment:
            fmt.print(v.identifier.raw, " = ")
            gen_expression(v.expression)
            fmt.println(";")
            

        case Call:
            fmt.println(v.identifier.raw, "();")

        case Begin:
            fmt.println("{")
            for s in v.statements do gen_statement(s)
            fmt.println("}")

        case If:
            fmt.print("if (")
            gen_condition(v.condition)
            fmt.println(") {")
            gen_statement(v.statement^)
            fmt.println("}")

        case While:
            fmt.print("while (")
            gen_condition(v.condition)
            fmt.println(") {")
            gen_statement(v.statement^)
            fmt.println("}")

        case Read:
            fmt.printf("scanf(\"%%d\", &{});\n", v.identifier.raw)

        case Write:
            fmt.print("printf(\"%d\\n\", ")
            gen_expression(v.expression)
            fmt.print(");\n")
    }
}

gen_block :: proc(block: Block) {
    gen_statement(block.statement)
}

codegen :: proc(using symbol_table: Symbol_Table, block: Block) {
    fmt.println("#include <stdio.h>")
    
    for ident, val in all_consts {
        fmt.println("int", ident.raw, "=", val, ";")
    }
    for var in all_vars {
        fmt.println("int", var.raw, ";")
    }

    // forward declare all procs first
    for ident in all_procedures {
        fmt.println("void", ident.raw, "();")
    }
    
    for ident, proc_block in all_procedures {
        fmt.println("void", ident.raw, "() {")
        gen_block(proc_block)
        fmt.println("}")
    }

    fmt.println("int main(void) {")
    gen_block(block)
    fmt.println("}")
}
