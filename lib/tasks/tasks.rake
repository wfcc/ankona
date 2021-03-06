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

desc "Delete wrong marks"
task wrong_marks: :environment do
  competition = ENV['competition']
  abort 'provide "competition={id}"' unless competition.present?
  
  c = Competition.find_by_id competition
  abort "Competition id #{competition} not found" unless c
  abort "Competition id #{competition} is not set to automatic sections." unless c.automatic?
  c.sections.each do |s|
    s.diagrams.each do |d|
      puts "Section: #{s.pattern} Id: #{d.id} Stip: [#{d.stipulation}] (converted to #{d.stipulation_classified})"
      d.marks.each do |m|
        if m.section.id != s.id
          puts "    ...delete mark #{m.id}"
          m.delete
        end
      end
    end
  end

  

end
desc "Automate competition"
task :automate_sections => :environment do

  competition = ENV['competition']
  abort 'provide "competition={id}"' unless competition.present?
  
  c = Competition.find_by_id competition
  abort "Competition id #{competition} not found" unless c
  abort "Competition id #{competition} is not set to automatic sections." unless c.automatic?
  
  c.sections.each do |s|
    s.diagrams.each do |d|
      puts "Section: #{s.pattern} Id: #{d.id} Stip: [#{d.stipulation}] (converted to #{d.stipulation_classified})"
      next if s.pattern == d.stipulation_classified
      puts '   ...moving...'
      r = c.sections.find{|ss| ss.pattern == d.stipulation_classified }
      unless r
        r = Section.new competition: c, pattern: d.stipulation_classified
        r.save
      end
      r.diagrams << d
      s.diagrams.delete d
      d.marks.clear
    end
  end

end

desc "Assign codes"
task :au_codes => :environment do

  Author.where('source Is Not Null').each do |author|
    author.save
    puts "#{author.code}   #{author.name}"
  end
end

desc 'Fairy pieces to JSON'
task pieces: :environment do
  ActiveRecord::Base.include_root_in_json = false
  pieces = Piece.all.to_json except: [:id, :created_at, :updated_at]
  File.open Rails.root.join('app/assets/javascripts/fairy-pieces.js'), 'w' do |file|
    file.write '(function() { ik.pieces = '
    file.write pieces
    file.write '})(jQuery)'
  end
end

desc 'Duplicate marks'
task dupmarks: :environment do
  Diagram.all.each do |d|
    d.marks.group_by(&:user_id).each do |u, mm|
      next unless mm.many?
      puts "Diagram #{d.id}"
      mm.each do |m|
        puts "   -- #{m.id}: u- #{m.user_id} (#{m.nummark}) [#{m.comment}] "
      end
      max = mm.reduce do |memo, m|
        memo.comment.size > m.comment.size ? memo : m
      end
      mmx = mm.reject{|m| m.id == max.id}
      puts mmx.map(&:id).inspect
      Mark.delete mmx
    end
  end
end


namespace :db do
  desc 'Create YAML test fixtures from data in an existing database.  
  Defaults to development database. Set RAILS_ENV to override.'

  task :extract_fixtures => :environment do
    sql = "SELECT * FROM %s"
    skip_tables = ["schema_info", "sessions"]
    ActiveRecord::Base.establish_connection
    tables = ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : ActiveRecord::Base.connection.tables - skip_tables
    tables.each do |table_name|
      i = "000"
      File.open("#{RAILS_ROOT}/test/fixtures/#{table_name}.yml", 'w') do |file|
        data = ActiveRecord::Base.connection.select_all(sql % table_name)
        file.write data.inject({}) { |hash, record|
          hash["#{table_name}_#{i.succ!}"] = record
          hash
        }.ya2yaml
      end
    end
  end
end

