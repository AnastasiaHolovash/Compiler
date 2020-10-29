add_executable(4-05-Swift-IV-82-Holovash
  4-05-Swift-IV-82-Holovash.swift)

# add_subdirectory(Source)
target_sources(4-05-Swift-IV-82-Holovash PRIVATE
  Compiler/Lexer.swift
  Compiler/Variables.swift
  Compiler/Extensions.swift
  Compiler/Token.swift
  Compiler/TreePrinter.swift
  
  Compiler/Parser/Parser.swift
  Compiler/Parser/CodeBlockParesr.swift
  Compiler/Parser/DeclarationParser.swift
  Compiler/Parser/IfStatementParser.swift
  Compiler/Parser/ExpressionParser.swift
  Compiler/Parser/CodeBlockParesr.swift
  Compiler/Parser/Parser+ErrorExtension.swift
  Compiler/Parser/Parser+Helpers.swift
  
  Compiler/Nodes/CodeBlock.swift
  Compiler/Nodes/Function.swift
  Compiler/Nodes/ReturnStatement.swift
  Compiler/Nodes/IfStatement.swift
  Compiler/Nodes/InfixOperation.swift
  Compiler/Nodes/PrefixOperation.swift
  Compiler/Nodes/Variable.swift
  Compiler/Nodes/Number.swift
  Compiler/Nodes/Identifier.swift

)


# FIXME(SR-12683) `@main` requires `-parse-as-library`
target_compile_options(4-05-Swift-IV-82-Holovash PRIVATE -parse-as-library)
target_link_libraries(4-05-Swift-IV-82-Holovash PRIVATE SwiftWin32)
