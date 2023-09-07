# softpack-env-from-module
Create an environment from an SHPC-style module file.

## Usage

```
addModuleToSoftpack.sh path_to_module_file module_load_path environment_path
```

In addition, the `SOFTPACK_CORE_URL` environmental variable must be set to the graphql endpoint for Softpack Core.

## Example Usage

```
addModuleToSoftpack.sh /software/module/HGI/shpc/ldsc/1.0.1--pyhdfd78af_2 HGI/shpc/ldsc/1.0.1--pyhdfd78af_2 users/mw31/ldsc
```
