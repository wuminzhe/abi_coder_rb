content = ""
Dir["./lib/**/*.rb"].each do |f|
  content += "\n# #{f}\n"
  File.open(f, "r").each_line do |line|
    content += line unless line.include?("require") || line.strip.start_with?("#") || line.strip.empty?
  end
end

puts content
