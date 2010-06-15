class SigsController < ApplicationController
  before_filter :find_sig, :only => [:show]

  def index

  end

  def show

  end

  protected
  def find_sig
    @sig = SpecialInterestGroup.find(params[:id])
    @sig || resource_not_found
  end
end
