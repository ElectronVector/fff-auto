# FFF Automatic Mock Generation

This can be used to mock C header files with the [Fake Function Framework](https://github.com/meekrosoft/fff) (fff).

Usage:
```
ruby fff.rb header.h [OUTPUT_DIR]
```

This will create a mock_header.h file in the provided output directory. If no OUTPUT_DIR is provided, then it will just be created here.

The mock header file can be included in your tests instead of the real module defined in the original header file.

## Testing

Run the tests with:

```
rspec spec/fff_generator_spec.rb
```

## Implementation

This uses the C header file parser used by [CMock](https://github.com/ThrowTheSwitch/CMock).

## To Do

- Add support for `const` arguments.
