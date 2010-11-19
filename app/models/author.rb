class Author < ActiveRecord::Base
  has_and_belongs_to_many :diagrams

  validates_presence_of :name

  cattr_reader :per_page
  @@per_page = 99
  
  before_save :generate_code

protected
#  def validate
#    errors.add_on_empty %w( birth_date ), 'No birth date'
#  end
  def generate_code
    
    return unless self.code.blank?
    
    nname = self.name.mb_chars.normalize(:kd).gsub(/[^\x20-\x7F]/,'').upcase.to_s
    nname =~ /^(.+)\s+(\S+)$/
    names, family = $1[0,1], $2[0,2]
    
    others = Author
      .where('code Is Not Null')
      .where(:code.matches => family + '%' + names)

    limit = 8 ** others.size.to_s(8).size # how many digits we need?

    while true
      trycode = family + (2 + rand(limit)).to_s + names
      unless others.find {|i| i.code == trycode}
        self.code = trycode
        logger.info "*** #{trycode} ***"
        break
      end
    end
  end

end
