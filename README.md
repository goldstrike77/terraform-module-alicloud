### Standard Module Structure
The standard module structure is a file and directory layout we recommend for reusable modules distributed in separate repositories. Terraform tooling is built to understand the standard module structure and use that structure to generate documentation, index modules for the module registry, and more.

The standard module structure expects the layout documented below.

#### README.
The root module and any nested modules should have README files. This file should be named README or README.md. The latter will be treated as markdown. There should be a description of the module and what it should be used for. If you want to include an example for how this module can be used in combination with other resources, put it in an examples directory like this. Consider including a visual diagram depicting the infrastructure resources the module may create and their relationship.

The README doesn't need to document inputs or outputs of the module because tooling will automatically generate this. If you are linking to a file or embedding an image contained in the repository itself, use a commit-specific absolute URL so the link won't point to the wrong version of a resource in the future.

#### LICENSE.
The license under which this module is available. If you are publishing a module publicly, many organizations will not adopt a module unless a clear license is present. We recommend always having a license file, even if it is not an open source license.

#### Variables and outputs should have descriptions.
All variables and outputs should have one or two sentence descriptions that explain their purpose. This is used for documentation. See the documentation for variable configuration and output configuration for more details.

#### resources.tf, variables.tf, outputs.tf, locals.tf.
These are the recommended filenames for a minimal module, even if they're empty. resources.tf should be the primary entrypoint. For a simple module, this may be where all the resources are created. variables.tf and outputs.tf should contain the declarations for variables and outputs, respectively.

A minimal recommended module following the standard structure is shown below. While the root module is the only required element, we recommend the structure below as the minimum:

```hcl
.
├── README.md
├── locals.tf
├── outputs.tf
├── resources.tf
└── variables.tf
```