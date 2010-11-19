# coding: utf-8
desc "Import text to authors"
task :txt2au => :environment do
  
  file = Rails.root.join 'database', 'authors-hannu.csv'
  f = File.open file, 'r'
  f.each_line do |line|
    line.gsub! /\"|\n/, ''
    line =~ /^(\S+)\s+(.+)$/
    family, name = $1, $2
    capline = line.mb_chars.normalize(:kd).gsub(/[^\x20-\x7F]/,'').upcase.to_s
    capline =~ /^(\S+)\s+(.+)$/
    puts "#{line}; #{capline}; #{name} #{family}"
    a = Author.new
    a.source = 'h'
    a.name = "#{name} #{family}"
    a.save    
  end
end

desc "Assign codes"
task :au_codes => :environment do

  Author.where('source Is Not Null').each do |author|
    author.save
    puts "#{author.code}   #{author.name}"
  end
end


