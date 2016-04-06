require_relative 'cmock_header_parser'
require_relative 'cmock_config'
require_relative 'fff_generator.rb'

$QUICK_RUBY_VERSION = RUBY_VERSION.split('.').inject(0){|vv,v| vv * 100 + v.to_i }

# Command line support.

if ($0 == __FILE__)
  usage =   "usage: ruby #{__FILE__} FILE [OUTPUT_DIR]\n" +
            "  FILE: a C header file to generate an FFF mock for.\n" +
            "  [OUTPUT_DIR]: where to put the output, defaults to ."

  if (!ARGV[0])
    puts usage
    exit 1
  end

  output_dir = "."
  if (ARGV[1])
      output_dir = ARGV[1]
  end

  # Setup the CMock header parser.
  options = nil
  cm_config = CMockConfig.new(options)
  cm_parser = CMockHeaderParser.new(cm_config)

  # Get the basename (without the extension) of the file that we're mocking.
  file_to_mock = ARGV[0]
  name = File.basename(file_to_mock, '.h')

  # Parse the header file.
  parsed_header = cm_parser.parse(name, File.read(file_to_mock))

  # Generate the mock file.
  file_to_create = File.join(output_dir, "mock_#{name}.h")
  puts file_to_create
  output_file = File.open(file_to_create, 'w')
  FffGenerator.create_mock(name, output_file, parsed_header)
  output_file.close()

end
