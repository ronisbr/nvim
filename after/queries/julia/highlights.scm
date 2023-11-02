;; extends

(assignment
  (identifier) @assignment)

(assignment
  (field_expression
    value: (identifier)
    (identifier) @assignment))

(macrocall_expression
  (macro_identifier) @function.macro.call)
(macrocall_expression
  (macro_identifier (identifier) @function.macro.call))

(string_interpolation) @string.interpolation
(string_interpolation
  ["(" (identifier) ")"] @string.interpolation)
