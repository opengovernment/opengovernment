class Session < ActiveRecord::Base
  belongs_to :legislature
  has_many :roles
  has_many :bills

  scope :active, :conditions => ["date_part('year', current_timestamp) between sessions.start_year and sessions.end_year"]
  scope :for_year, lambda { |year| where('? between sessions.start_year and sessions.end_year', year) }

  scope :complete, :conditions => ['sessions.id in (select distinct session_id from roles)']
  scope :most_recent, lambda { |legislature_id| complete.where(["legislature_id = ?", legislature_id]).order('sessions.end_year desc').limit(1) }
  scope :major, :conditions => ['sessions.parent_id is null']

  validates_uniqueness_of :name, :scope => :legislature_id

  has_many :children, :class_name => 'Session', :foreign_key => 'parent_id', :dependent => :destroy
  belongs_to :parent, :class_name => 'Session'

  # Return the parent and all children for this session.
  def family
    parent_id? ? [parent, *parent.children] : [self, *children]
  end

  def primary_id
    parent_id? ? parent_id : self[:id]
  end

  def primary
    parent_id? ? parent : self
  end

  def latest?
    most_recent_session = Session.most_recent(self.legislature_id)

    if most_recent_session.try(:first).try(:id) == self[:id]
      true
    else
      false
    end
  end

  def to_param
    name.parameterize
  end

  def name_fm
    # Fix session names that look like 20092010 (2009-2010) or 81 (81st).
    if name =~ /^(\d{4})(\d{4})$/
      "#{$1}-#{$2}"
    elsif name =~ /^(\d{2,3})$/
      $1.to_i.ordinalize
    else
      name
    end
  end

  def special_number
    if parent_id?
      [/\d+ (\d+)[stndh]+ extraordinary session/,
      /\d+ special session (\d+)/,
      /^\d{4}s(\d+)$/].each do |re|
        return $1.to_i if name.downcase =~ re
      end
      return nil
    end
  end
end
