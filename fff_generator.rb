class FffGenerator

@header = %{
/*
    Auto-generated mock file for FFF.
*/

#include <string.h>
#include "fff.h"

DEFINE_FFF_GLOBALS;

}

    # mock_name is the base of the file to be mocked. For example, when mocking
    # display.h, mock_name should be "display."
    def self.create_mock (mock_name, output_stream, parsed_header_file)
        include_guard_name = "mock_" + mock_name + "_H"
        output_stream.puts "#ifndef #{include_guard_name}"
        output_stream.puts "#define #{include_guard_name}"
        output_stream.puts @header

        # Handle the typedefs.
        if parsed_header_file.key?(:typedefs)
            parsed_header_file[:typedefs].each do |typedef|
            output_stream.puts typedef
            end
            output_stream.puts
        end

        # Handle the functions.
        if parsed_header_file.key?(:functions)
            # Generate mocks for each function.
            parsed_header_file[:functions].each do |function|
                # Add a reset for this function.
                if function[:return][:type] == "void"
                    # Start to mock a function returning void.
                    output_stream << "FAKE_VOID_FUNC(" + function[:name]
                else
                    # Start to mock a function returning a value.
                    output_stream << "FAKE_VALUE_FUNC(" +
                        function[:return][:type] + ", " + function[:name]
                end
                # Add the argument types.
                function[:args].each do |arg|
                    output_stream << ", "
                    output_stream << arg[:type]
                end
                output_stream.puts ");"
            end
        end

        # Create the reset macro to reset all of the mocks in this file.
        if parsed_header_file.key?(:functions) && parsed_header_file[:functions].count > 0
            output_stream.puts
            output_stream.puts "#define RESET_MOCK_" + mock_name.upcase  + "() \\"
            parsed_header_file[:functions].each do |function|
                output_stream << "    RESET_FAKE(" + function[:name] + ");"
                if function != parsed_header_file[:functions].last
                    # Continue the macro for all but the last line.
                    output_stream << " \\"
                end
                output_stream.puts
            end
        end

        output_stream.puts
        output_stream.puts "#endif // #{include_guard_name}"
    end
end
