class Competition < ActiveRecord::Base
  belongs_to :user
  has_many :sections, dependent: :destroy
  #after_update :save_sections
  accepts_nested_attributes_for :sections, allow_destroy: true,
    reject_if: proc { |a| a['name'].blank? }
  validates_presence_of :name

  class << self  
    def public(user)
      where(:status >> 1)
      .where(:user_id >> user.id | (:private >> nil | :private >> false))
    end
  end
  

  def save_sections
    sections.each do |section|
      section.save false
    end
  end

  def existing_section_attributes=(section_attributes)
    sections.reject(&:new_record?).each do |section|
      attributes = section_attributes[section.id.to_s]
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
