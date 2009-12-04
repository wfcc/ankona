namespace :populate do
  desc 'diagrams'
  task (:diagrams => :environment) do
    Author.connection.execute 'TRUNCATE authors'
    Diagram.connection.execute 'TRUNCATE diagrams'
    Diagram.connection.execute 'TRUNCATE authors_diagrams'
    puts ''
    LDiagrams.find_each do |diagram|
      attri = diagram.attributes
#      id = attri.delete 'id'
      printf "\n%s .....\n", attri['id']
#      next if attri['id'] <= 65981
      # we will preserve the ID
      old_authors = attri.delete 'author'
      next if attri['id'].to_i < 1
      next if not attri['position']
      next if not old_authors or old_authors.empty?
      next if old_authors =~ /MENUITEM/
      old_date = attri.delete 'date'
      attri.delete 'fc'
      attri.delete 'fp'
      nd = Diagram.new attri
      nd.id = attri['id'].to_i
      nd.published = old_date
      nd.save :false
      old_authors.split(/\s*[\&;]\s*/).each do |author|
        if author =~ /,/
          author = author.split(/\s*,\s*/).reverse.join ' '
        end
        author = author.split(/ /).collect do |x|
          x.capitalize! unless x =~ /\.|\-/
          x[2] = x[2,1].upcase if
            x =~ /^Mc\w/ or
            x =~ /^O\'\w/ or
            x =~ /^D\'\w/
          # Shall provide for McNab, D'Orville, O'Connell
          x
        end.join ' '
        printf "\t%s\n", author
        nd.authors << Author.find_or_create_by_name(author)
      end if old_authors
    end
    puts
  end
  desc 'users'
  task (:users => :environment) do
    User.connection.execute 'TRUNCATE users'
    LUsers.find_each do |u|
      id = u.id
      attri = u.attributes
      attri.delete("id")
      new = User.new attri
      new.id = id
      new.crypted_password = u.password
      new.save false
    end
    print "*** #{User.count} records added ***\n"
  end
  desc 'posts'
  task (:posts => :environment) do
    Post.connection.execute 'TRUNCATE posts'
    LPost.find_each do |u|
      id = u.id
      attri = u.attributes
      attri.delete 'id'
      attri[:created_at] = attri.delete 'time'
      new = Post.new attri
      new.id = id
      new.save false
    end
    print "*** #{Post.count} records added ***\n"
  end
  desc 'collections'
  task (:collections => :environment) do
    Collection.connection.execute 'TRUNCATE collections'
    LCollection.find_each do |collection|
#      puts collection.attributes.inspect
      id =  collection.attributes['id']
      new = Collection.new collection.attributes
      new.id = id
      new.save
    end
    print "*** #{Collection.count} records added ***\n"
  end
  desc 'collections_diagrams'
  task (:collections_diagrams => :environment) do
    Collection.connection.execute 'DROP TABLE collections_diagrams'
    Collection.connection.execute 'CREATE TABLE collections_diagrams SELECT * FROM l_diagrams_collections'
  end
end
