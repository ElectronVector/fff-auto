require 'stringio'
require_relative '../fff_generator.rb'

expected_header = %{#include <string.h>
#include "fff.h"

DEFINE_FFF_GLOBALS;
}



# Create the CMock-style parsed header hash.
# Need to add handling for arguments.
def create_parsed_header(functions, typedefs = nil)
    parsed_header = {
        :includes => nil,
        :functions => [],
        :typedefs => []
    }

    # Add the typedefs.
    if typedefs
        typedefs.each do |typedef|
            parsed_header[:typedefs] << typedef
        end
    end

    # Add the functions.
    if functions
        functions.each do |function|
            # Build the array of arguments.
            args = []
            if function.key?(:args)
                function[:args].each do |arg|
                    args << {
                        :type => arg
                    }
                end
            end
            parsed_header[:functions] << {
                :name => function[:name],
                :modifier => "",
                :return => {
                    :type => function[:return_type],
                    :name => "cmock_to_return",
                    :ptr? => false,
                    :const? => false,
                    :str => "void cmock_to_return",
                    :void? => true
                },
                :var_arg => nil,
                :args_string => "void",
                :args => args,
                :args_call => "",
                :contains_ptr? => false
            }
        end
    end
    parsed_header
end

describe FffGenerator do

    # TODO
    # Handle const args.

    context "when there is nothing to mock," do
        parsed_header = Hash.new
        mock_file = StringIO.new
        FffGenerator.create_mock("display", mock_file, parsed_header)
        it "then the generated file contains a header" do
            expect(mock_file.string).to include(expected_header)
        end
        it "then the generated file does not contain a reset function" do
            expect(mock_file.string).not_to include("define RESET_MOCK_")
        end

        it "then the generated file starts with an opening guard" do
            expect(mock_file.string).to start_with(
                "#ifndef mock_display_H\n" +
                "#define mock_display_H")
        end

        it "then the generated file ends with a closing include guard" do
            expect(mock_file.string).to end_with(
                "#endif // mock_display_H\n")
        end
    end

    context "when there is a function with no args and a void return," do
        parsed_header = create_parsed_header(
            [{:name => 'display_turnOffStatusLed', :return_type => 'void'}]
        )
        mock_file = StringIO.new
        FffGenerator.create_mock("display", mock_file, parsed_header)
        it "then the generated file contains a header" do
            expect(mock_file.string).to include(expected_header)
        end
        it "then the generated file contains a generated mock" do
            expect(mock_file.string).to include(
                "FAKE_VOID_FUNC(display_turnOffStatusLed);"
            )
        end
        it "then the generated file contains no other generated mocks" do
            expect(mock_file.string.scan("_FUNC(").count).to eq(1)
        end
        it "then the generated file contains a reset function" do
            expect(mock_file.string).to include("#define RESET_MOCK_DISPLAY()")
            expect(mock_file.string).to include("RESET_FAKE(display_turnOffStatusLed);")
        end
        it "then the generated file does not contain any other reset functions" do
            expect(mock_file.string.scan("RESET_FAKE(").count).to eq(1)
        end
    end

    context "when there is a function with no args and a bool return," do
        parsed_header = create_parsed_header(
            [{:name => 'display_isError', :return_type => 'bool'}]
        )
        mock_file = StringIO.new
        FffGenerator.create_mock("display", mock_file, parsed_header)
        it "then the generated file contains a header" do
            expect(mock_file.string).to include(expected_header)
        end
        it "then the generated file contains the generated mock" do
            expect(mock_file.string).to include(
                "FAKE_VALUE_FUNC(bool, display_isError);"
            )
        end
        it "then the generated file contains a reset function" do
            expect(mock_file.string).to include("#define RESET_MOCK_DISPLAY()")
            expect(mock_file.string).to include("RESET_FAKE(display_isError);")
        end
    end

    context "when there are two functions to mock," do
        parsed_header = create_parsed_header(
            [
                {:name => 'display_turnOffStatusLed', :return_type => 'void'},
                {:name => 'display_isError', :return_type => 'bool'}
            ]
        )
        mock_file = StringIO.new
        FffGenerator.create_mock("display", mock_file, parsed_header)
        it "then there are mocks for both functions" do
            expect(mock_file.string).to include(
                "FAKE_VOID_FUNC(display_turnOffStatusLed);"
            )
            expect(mock_file.string).to include(
                "FAKE_VALUE_FUNC(bool, display_isError);"
            )
        end
    end

    context "when there is a function with args and a void return," do
        parsed_header = create_parsed_header([{
            :name => 'display_setVolume',
            :return_type => 'void',
            :args => ['int']
        }])
        mock_file = StringIO.new
        FffGenerator.create_mock("display", mock_file, parsed_header)
        it "then the generated file contains the generated mock" do
            expect(mock_file.string).to include(
                "FAKE_VOID_FUNC(display_setVolume, int);"
            )
        end
        it "then the generated file contains a reset function" do
            expect(mock_file.string).to include("#define RESET_MOCK_DISPLAY()")
            expect(mock_file.string).to include("RESET_FAKE(display_setVolume);")
        end
    end

    context "when there is a function with args and a value return," do
        parsed_header = create_parsed_header([{
            :name => 'display_anotherFunction',
            :return_type => 'int',
            :args => ['char *']
        }])
        mock_file = StringIO.new
        FffGenerator.create_mock("display", mock_file, parsed_header)
        it "then the generated file contains the generated mock" do
            expect(mock_file.string).to include(
                "FAKE_VALUE_FUNC(int, display_anotherFunction, char *);"
            )
        end
    end

    context "when there is a function with multipe args," do
        parsed_header = create_parsed_header([{
            :name => 'display_getKeyboardEntry',
            :return_type => 'void',
            :args => ['char *', 'int']
        }])
        mock_file = StringIO.new
        FffGenerator.create_mock("display", mock_file, parsed_header)
        it "then the generated file contains the generated mock" do
            expect(mock_file.string).to include(
                "FAKE_VOID_FUNC(display_getKeyboardEntry, char *, int);"
            )
        end
    end

    context "when there is a typedef," do
        parsed_header = create_parsed_header(
            nil,
            ["typedef void (*displayCompleteCallback) (void);"]
        )
        mock_file = StringIO.new
        FffGenerator.create_mock("display", mock_file, parsed_header)
        it "then the generated file contains the typedef" do
            expect(mock_file.string).to include(
                "typedef void (*displayCompleteCallback) (void);"
            )
        end
    end

    context "when there is a function to mock and the mock has another name," do
        parsed_header = create_parsed_header(
            [{:name => 'printer_print', :return_type => 'void', :args => ['char *'] }]
        )
        mock_file = StringIO.new
        FffGenerator.create_mock("printer", mock_file, parsed_header)
        it "then the generated file contains a reset function of the correct name" do
            expect(mock_file.string).to include("#define RESET_MOCK_PRINTER()")
            expect(mock_file.string).to include("RESET_FAKE(printer_print);")
        end
    end
end
