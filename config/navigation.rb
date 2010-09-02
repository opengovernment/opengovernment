# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|  
  # Specify a custom renderer if needed. 
  # The default renderer is SimpleNavigation::Renderer::List which renders HTML lists.
  # The renderer can also be specified as option in the render_navigation call. 
  # navigation.renderer = Your::Custom::Renderer
  
  # Specify the class that will be applied to active navigation items. Defaults to 'selected'
  # navigation.selected_class = 'your_selected_class'
    
  # Item keys are normally added to list items as id.
  # This setting turns that off
  # navigation.autogenerate_item_ids = false
  
  # You can override the default logic that is used to autogenerate the item ids.
  # To do this, define a Proc which takes the key of the current item as argument.
  # The example below would add a prefix to each key.
  # navigation.id_generator = Proc.new {|key| "my-prefix-#{key}"}

  # The auto highlight feature is turned on by default.
  # This turns it off globally (for the whole plugin)
  # navigation.auto_highlight = false

  # Define the primary navigation
  navigation.items do |primary|
    # Add an item to the primary navigation. The following params apply:
    # key - a symbol which uniquely defines your navigation item in the scope of the primary_navigation
    # name - will be displayed in the rendered navigation. This can also be a call to your I18n-framework.
    # url - the address that the generated item links to. You can also use url_helpers (named routes, restful routes helper, url_for etc.)
    # options - can be used to specify attributes that will be included in the rendered navigation item (e.g. id, class etc.)
    #           some special options that can be set:
    #           :if - Specifies a proc to call to determine if the item should
    #                 be rendered (e.g. <tt>:if => Proc.new { current_user.admin? }</tt>). The
    #                 proc should evaluate to a true or false value and is evaluated in the context of the view.
    #           :unless - Specifies a proc to call to determine if the item should not
    #                     be rendered (e.g. <tt>:unless => Proc.new { current_user.admin? }</tt>). The
    #                     proc should evaluate to a true or false value and is evaluated in the context of the view.
    #           :method - Specifies the http-method for the generated link - default is :get.
    #           :highlights_on - if autohighlighting is turned off and/or you want to explicitly specify 
    #                            when the item should be highlighted, you can set a regexp which is matched 
    #                            against the current URI.
    #
    primary.item :bills, 'Bills', bills_path, :class => 'bills' do |bill|
      if !@bill.nil?
        bill.item :bill, @bill.bill_number, bill_path(@bill.session, @bill), :class => 'bill' do |m|
          m.item :overview, 'Overview', bill_path(@bill.session, @bill)
          m.item :votes, 'Votes', '#'
          m.item :citations, 'News & Blog Coverage', news_bill_path(@bill.session, @bill)
          m.item :tweets, 'Social Media Coverage', '#'
          m.item :video, 'Video', '#', :class => 'inactive'
          m.item :money_trail, 'Money Trail', '#', :class => 'inactive'
        end
      end
    end
    primary.item :people, 'People', people_path, :class => 'people' do |person|
      if !@person.nil?
        person.item :person, @person.full_name, person_path(@person), :class => "person #{@person.gender_class}" do |m|
          m.item :overview, 'Overview', person_path(@person)
          m.item :bills, 'Bills Sponsored', sponsored_bills_person_path(@person)
          m.item :citations, 'News & Blog Coverage', news_person_path(@person)
          m.item :votes, 'Votes', votes_person_path(@person)
          m.item :money_trail, 'Money Trail', '#'
        end
      end
    end
    primary.item :issues, 'Issues', issues_path
    primary.item :votes, 'Votes', '#', :if => Proc.new { !@vote.nil? } do |m|
      if !@vote.nil?
        m.item :vote, @vote.bill.bill_number, vote_path(@vote), :class => "vote #{@vote.outcome_class}"
      end
    end
    primary.item :money_trail, 'Money Trail', '#'

    # Add an item which has a sub navigation (same params, but with block)
    #primary.item :key_2, 'name', url, options do |sub_nav|
      # Add an item to the sub navigation (same params again)
    #  sub_nav.item :key_2_1, 'name', url, options
    #end 
  
    # You can also specify a condition-proc that needs to be fullfilled to display an item.
    # Conditions are part of the options. They are evaluated in the context of the views,
    # thus you can use all the methods and vars you have available in the views.
    #primary.item :key_3, 'Admin', url, :class => 'special', :if => Proc.new { current_user.admin? }
    #primary.item :key_4, 'Account', url, :unless => Proc.new { logged_in? }

    # you can also specify a css id or class to attach to this particular level
    # works for all levels of the menu
    # primary.dom_id = 'menu-id'
    # primary.dom_class = 'menu-class'
    
    # You can turn off auto highlighting for a specific level
    # primary.auto_highlight = false
  
  end
  
end