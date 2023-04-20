# Terraform AWS Dynamic Security Groups Module

This Terraform module creates security groups and their associated ingress/egress rules based on a provided markdown table.
## Usage

To use this module, you need to have a markdown file with the security group rules formatted as shown in the example below:

```markdown
| Security Groups / inbound from => | frontend                                                                                      | backend                                                | database | ssm(/security_groups/external_server)                                                                   | cidr(10.0.0.0/8)                         |
|-----------------------------------|-----------------------------------------------------------------------------------------------|--------------------------------------------------------|----------|---------------------------------------------------------------------------------------------------------|------------------------------------------|
| frontend                          |                                                                                               |                                                        |          | [{"port": 80, "description": "external server"}, {"port": 443, "description": "external server https"}] | [{"port": 443, "description": "public"}] |
| backend                           | [{"port": 80, "description": "from frontend"}, {"port": 443, "description": "from frontend"}] |                                                        |          |                                                                                                         |                                          |
| database                          |                                                                                               | [{"port": 1433, "description": "database connection"}] |          |                                                                                                         |                                          |
```

## Example
```hcl
module "dynamic_security_groups" {
  source              = "path/to/this/module"
  vpc_id              = "vpc-12345678"
  markdown_file_path  = "path/to/markdown_file.md"
}
```

## Additional Notes

    This module supports CIDR blocks and referencing other security groups by name as the source. Additionally, you can use SSM parameters to fetch security group IDs from an external source.
    The markdown file should be formatted correctly for the module to work as expected. Please refer to the provided example above.