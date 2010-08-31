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

  has_many :sub_sessions, :class_name => 'Session', :foreign_key => 'parent_id', :dependent => :destroy

  def to_param
    name.parameterize
  end
  
  def name_fm
    "#{name}" + "(#{start_year} &ndash; #{end_year})"
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
