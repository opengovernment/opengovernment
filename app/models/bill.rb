class Bill < ActiveRecord::Base
  belongs_to :state
  belongs_to :session
  belongs_to :chamber

  has_many :sponsorships, :dependent => :destroy
  has_many :sponsors, :through  => :sponsorships

  has_many :versions, :dependent => :destroy
  has_many :actions, :dependent => :destroy
  has_many :votes, :dependent => :destroy
  
  # How will we allow people to sort bills?
  SORTABLE_BY = ['title','first_action_at','last_action_at','bill_number'].freeze

  named_scope :titles_like, lambda { |t| { :conditions => ["upper(bill_number) = ? or title like ?", "#{t.gsub(/[-.\s]/,'').upcase.sub(/(([A-Z]\.?-?\s*){1,2})(\d+)/, '\1 \3')}", "%#{t}%"] } }
  named_scope :in_chamber, lambda { |c| { :conditions => ["chamber_id = ?", c] } }
  named_scope :for_session, lambda { |s| { :conditions => ["session_id = ?", s], :joins => [:session] }  }
  named_scope :for_session_named, lambda { |s| { :conditions => ["sessions.name = ?", s], :joins => [:session] } }

  named_scope :for_state, lambda { |s| {:conditions => ["state_id = ?", s] } }

  class << self
    def find_by_session_name_and_param(session, param)
      for_session_named(session).find_by_bill_number(param.titleize.upcase)
    end

    def search(params)
      scope = Bill.scoped({})
      scope = scope.titles_like(params[:q]) if params[:q]
      scope = scope.for_session(params[:session_id]) if params[:session_id]
      scope = scope.in_chamber(params[:chamber_id]) if params[:chamber_id]
      scope = scope.for_state(State.find_by_slug(params[:state_id])) if params[:state_id]
    end
  end

  def to_param
    bill_number.parameterize
  end
end
