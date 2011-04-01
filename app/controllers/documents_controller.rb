class DocumentsController < SubdomainController

  def show
    @document = BillDocument.find(params[:id])

    respond_to do |format|
      format.json do
        render :json => {:title => @document.name || '',
          :description => @document.description || '',
          :pages => @document.total_pages,
          :id => @document.to_param,
          :created_at => @document.created_at,
          :updated_at => @document.updated_at,
          :resources => {
            :page => {:text => @document.text_url_format, :image => @document.image_url_format},
            :pdf => @document.document.url
          }}
      end
      format.html do
        # Degrade based on whether we have full components,
        # or a local scraped document,
        # or just a URL.
        if @document.components_available?
          render :layout => false
        else
          redirect_to @document.document? ? @document.document.url : @document.url
        end
      end
    end

  end

end
