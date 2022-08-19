class DataTransformer(object):
    __slots__ = (
        "provider",
        "prefix",
        "transformation",
        "file_spec_handler",
        "target_file",
    )

    def __init__(self, provider, prefix, transformation, target_file):
        if not isinstance(provider, DataProviders):
            raise ValueError(
                f"Expected valid data provider enum, not: {type(provider)}"
            )
        if not isinstance(prefix, pathlib.Path):
            raise ValueError(f"Expected pathlib.Path, not: {type(prefix)}")
        self.provider = provider
        self.prefix = prefix
        if not isinstance(transform_spec, dict):
            # no transformation requested, return None
            return None
        transformation_type, transformation_spec = list()
        self.transformation = DataTransformations[transformation]
