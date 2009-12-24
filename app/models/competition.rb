class Competition < ActiveRecord::Base
  belongs_to :user
  has_many :sections, :dependent => :destroy
  after_update :save_sections
  validates_presence_of :name

  def save_sections
    sections.each do |section|
      section.save false
    end
  end

  def existing_section_attributes=(section_attributes)
    sections.reject(&:new_record?).each do |section|
      attributes = section_attributes[section.id.to_s]
      logger.info '>->> ' + attributes.inspect + ' <-<<'
      if attributes
        section.attributes = attributes
      else
        sections.delete(section)
      end
    end
  end

  def new_section_attributes=(section_attributes)
    section_attributes.each do |attributes|
      sections.build(attributes)
    end
  end
end
