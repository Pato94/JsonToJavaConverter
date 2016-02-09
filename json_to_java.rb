#!/usr/bin/ruby
require 'json'
require 'optparse'

class String
  def camel_case
    return self if self !~ /_/ && self =~ /[A-Z]+.*/
    split('_').map{|e| e.capitalize}.join
  end

  def uncapitalize
    self[0, 1].downcase + self[1..-1]
  end
end

class JsonToJavaConverter

  def parse args
    options = OpenStruct.new
    options.verbose = false
    options.camel_case = false

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: json_to_java.rb [options]"
      opts.separator ""
      opts.separator "Specific options:"

      opts.on("--parse a,b,d", Array, "List of items to be parsed, don't put a space between them") do |item|
        options.list = item
      end

      opts.on("--privacy [PRIVACY]", String, ["public", "private"], "Adding public/private to ALL the parsed fields") do |item|
        options.privacy = item
      end

      opts.on("--package [PACKAGE]", String, "The package of the new files (Something like be com.example.model)") do |item|
        options.package = item
      end

      opts.on("-c", "--[no-]camelcase", "Transform fields from snake_case to camelCase") do |cc|
        options.camel_case = cc
      end

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options.verbose = v
      end

      opts.separator ""
      opts.separator "Common options:"

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end

    opts.parse!(args)

    options
  end

  def parse_file file, file_name, verbose, privacy, camel_case, package

    @privacy_with_space = privacy || ""
    if @privacy_with_space.length > 0
      @privacy_with_space = @privacy_with_space + " "
    end
    @camel_case = camel_case
    @package = package

    parsed_json = JSON.parse(file.read)
    file.close
    if verbose
      puts "The parsed json is #{parsed_json}"
    end

    hash_of_types = map_to_types parsed_json

    write_to_file file_name, hash_of_types
    if verbose
      puts "The typo of these jsons is #{hash_of_types}"
    end
  end

  def map_to_types hash
    hash.each do |key, value|
      hash.store key, get_type(value)
    end
  end

  def get_type value
    if value.is_a? Hash
      map_to_types(value)
    elsif value.is_a? Array
      [get_type(value[0])]
    else
      value.class
    end
  end

  def get_java_type name, value
    if value == Fixnum
      "int"
    elsif value == Float
      "float"
    elsif value == String
      "String"
    elsif value == TrueClass || value == FalseClass
      "boolean"
    elsif value.is_a? Hash
      write_to_file name, value
      name
    else
      "Object"
    end
  end

  def write_to_file name, hash
    file = File.new(name + ".java", "w")
    if @package
      file.write "package #{@package};\n\n"
    end

    file.write "public class #{name} {\n"
    hash.each do |key, value|
      if @camel_case
        key = key.camel_case.uncapitalize
      end
      if value.is_a? Array
        file.write "  #{@privacy_with_space}List<#{get_java_type(name + key.capitalize, value[0])}> #{key};\n"
      else
        file.write "  #{@privacy_with_space}#{get_java_type(name + key.capitalize, value)} #{key};\n"
      end
    end
    file.write "}\n"
  end

end

converter = JsonToJavaConverter.new

options = converter.parse(ARGV)

if !options.list || options.list.empty?
  puts "No files received"
else
  options.list.each do |file_name|
    puts "Reading file: #{file_name}"

    file = File.new(file_name, "r")

    converter.parse_file file, file_name, options.verbose, options.privacy, options.camel_case, options.package
  end
end