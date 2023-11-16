content = "# Generated from https://github.com/wuminzhe/abi_coder_rb\n"
Dir["./lib/**/*.rb"].each do |f|
  File.open(f, "r").each_line do |line|
    content += line unless line.include?("require") || line.strip.start_with?("#") || line.strip.empty?
  end
end

puts content
