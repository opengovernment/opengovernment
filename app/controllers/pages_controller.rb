class PagesController < HighVoltage::PagesController
  caches_page :show
  
  layout "static"
end
