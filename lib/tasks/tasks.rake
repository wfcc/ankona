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

