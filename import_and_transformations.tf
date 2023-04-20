locals {
  markdown_table = file(var.markdown_file_path)

  table_rows = split("\n", local.markdown_table)

  rows_without_header            = slice(local.table_rows, 2, length(local.table_rows) - 1)
  table_rows_without_header_list = [for row in local.rows_without_header : split("|", row)]

  extracted = { for targets in local.table_rows_without_header_list :
    trimspace(element(targets, 1)) => [for index, rules in slice(targets, 2, length(targets) - 1) : {
      rules  = jsondecode(rules)
      source = element(local.targets, index)
    } if trimspace(rules) != ""]
  }

  targets = slice(split("|", replace(element(local.table_rows, 0), " ", "")), 2, length(local.table_rows) +1 )



  flattened_rules = flatten([
    for sg_name, sg in local.extracted : [
      for source in sg : [
        for rule in source.rules : {
          description = rule.description
          port        = rule.port
          source      = source.source
          target      = sg_name
        }
      ]
    ]
  ])
}

