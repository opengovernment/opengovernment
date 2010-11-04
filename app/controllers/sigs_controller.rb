class SigsController < ApplicationController
  before_filter :find_sig, :only => [:show]

  def index

  end

  def show
    @years_available = Rating.select("ratings.timespan").where(:sig_id => @sig.id).group(:timespan).collect { |r| r.timespan.to_s }.sort {|x,y| y <=> x }
    @year = params[:year] || @years_available.first
    @ratings = @sig.ratings.where(:timespan => @year)
  end

  protected
  def find_sig
    @sig = SpecialInterestGroup.find(params[:id])
    @sig || resource_not_found
  end
end
