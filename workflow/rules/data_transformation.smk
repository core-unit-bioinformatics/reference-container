import pathlib

# specific workflows for the use of data transformations
# as part of the pipeline
USE_DATA_TRANSFORMATION = config.get("use_data_transformation", False)
assert isinstance(USE_DATA_TRANSFORMATION, bool)

if USE_DATA_TRANSFORMATION:
    try:
        DATA_TRANSFORMATION_WORKFLOW = config["data_transformation_workflow"]    
    except KeyError:
        raise KeyError(
            "The config option 'use_data_transformation' is set to True. "
            "Consequently, the option 'data_transformation_workflow' must be "
            "set to an existing Snakefile on the file system containing the "
            "Snakemake workflow that should be used."
        )
    else:
        DATA_TRANSFORMATION_WORKFLOW = pathlib.Path(DATA_TRANSFORMATION_WORKFLOW).resolve(strict=True)
    
    from snakemake.utils import min_version
    min_version("6.0")

    module data_transformation_workflow:
        snakefile:
            DATA_TRANSFORMATION_WORKFLOW
    use rule * from data_transformation_workflow as data_transformation_*

else:
    pass
