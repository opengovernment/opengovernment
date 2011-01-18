class SigsController < SubdomainController
  before_filter :find_sig, :only => [:show]

  def index

  end

  def show
    @years_available = Rating.select("ratings.timespan").where(:sig_id => @sig.id).group(:timespan).collect { |r| r.timespan.to_s }.sort {|x,y| y <=> x }
    @year = params[:year] || @years_available.first


    @categories_available = Rating.select("ratings.rating_name").where(:sig_id => @sig.id, :timespan => @year).group(:rating_name).collect { |r| r.rating_name }.sort {|x,y| y <=> x }
    @category = params[:category] || @categories_available.first

    @ratings = @sig.ratings.where(:timespan => @year, :rating_name => @category)
  end

  protected
  def find_sig
    @sig = SpecialInterestGroup.find(params[:id])
    @sig || resource_not_found
  end
end
