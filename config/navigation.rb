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
    
    # OpenGovernment's navigation is only ever two levels deep.
    # Some third-level navigation is defined in this file, and it
    # never appears. But by defining it, we can highlight the appropriate level 1..2 items
    # when we want to.

    if controller_name == 'pages'
      primary.item :about, 'About OpenGovernment.org', page_url("about", :subdomain => false)
      primary.item :policy, 'Privacy Policy', page_url("privacy", :subdomain => false)
      primary.item :wishes, 'Wish List', page_url("wish-list", :subdomain => false)
      primary.item :help, 'Help', page_url("help", :subdomain => false)
      primary.item :contact, 'Contact Us', page_url("contact", :subdomain => false)
      primary.item :developer, 'Developer Hub', page_url('developer', :subdomain => false)
    else

      if controller_name == 'subjects'
        if defined?(@subject)
          primary.item :subject, 'Bill Subject', subject_path(params[:session], @subject, :subdomain => current_place_subdomain)
        else
          primary.item :subjects, 'Bill Subjects', subjects_path(params[:session])
        end
      end

      if defined?(@sig)
          primary.item :sig, 'Special Interest Group', sig_path(@sig)
      end

      if defined?(@vote)
        bill = @vote.bill
      elsif defined?(@action)
        bill = @action.bill
      elsif defined?(@bill)
        bill = @bill
      end

      if defined?(@vote) || defined?(@action) || defined?(@bill)
        primary.item :bill, bill.bill_number, bill_path(bill.session, bill), :class => 'bill' do |m|
          m.item :overview, 'Overview', bill_path(bill.session, bill)
          m.item :votes, 'Votes and Actions', votes_bill_path(bill.session, bill) do |v|
            if defined?(@vote)
              v.item :vote, 'Vote', vote_path(@vote)
            elsif defined?(@action)
              v.item :action, 'Action', action_path(@action)
            end
          end
          m.item :mentions, 'News & Blog Coverage', news_bill_path(bill.session, bill)
          m.item :tweets, 'Social Media Mentions', social_bill_path(bill.session, bill)
          m.item :money_trail, 'Interest Groups', money_trail_bill_path(bill.session, bill), :class => 'inactive'
          m.item :videos, 'Videos', videos_bill_path(bill.session, bill)
          m.item :disqus, 'Comments', discuss_bill_path(bill.session, bill, :anchor => 'disqus_thread')
        end
      end

      if defined?(@person)
        primary.item :person, @person.full_name, person_path(@person), :class => "person #{@person.gender_class}" do |m|
          m.item :overview, 'Overview', person_path(@person)
          m.item :votes, 'Votes', votes_person_path(@person)
          m.item :bills, 'Bills Sponsored', sponsored_bills_person_path(@person)
          m.item :tweets, 'Social Media Mentions', social_person_path(@person)
          m.item :mentions, 'News & Blog Coverage', news_person_path(@person)
          m.item :money_trail, 'Campaign Contributions', money_trail_person_path(@person)
          m.item :videos, 'Videos', videos_person_path(@person)
          m.item :disqus, 'Comments', discuss_person_path(@person, :anchor => 'disqus_thread')
          m.item :committees, 'Committees', committees_person_path(@person), :style => 'display: none;'
          m.item :ratings, 'Ratings', ratings_person_path(@person), :style => 'display: none;'
        end
      end

      primary.item :bills, 'Bills', bills_url(params[:session], :subdomain => current_place_subdomain), :class => 'bills primary-nav-bills primary-nav'
      primary.item :people, 'People', people_url(params[:session], :subdomain => current_place_subdomain), :class => 'people primary-nav-people primary-nav' do |p|
        if defined?(current_place)
          p.item :upper, "#{current_place.try(:upper_chamber).try(:short_name)} Committees", upper_committees_path do |c|
            if defined?(@committee) && @committee[:type] == 'UpperCommittee'
              c.item :committee, 'Committee', committee_path(@committee)
            end
          end
          p.item :lower, "#{current_place.try(:lower_chamber).try(:short_name)} Committees", lower_committees_path do |c|
            if defined?(@committee) && @committee[:type] == 'LowerCommittee'
              c.item :committee, 'Committee', committee_path(@committee)
            end
          end
          p.item :joint, "Joint Committees", joint_committees_path do |c|
            if defined?(@committee) && @committee[:type] == 'JointCommittee'
              c.item :committee, 'Committee', committee_path(@committee)
            end
          end
        end
      end

      # person.item :search, 'Find Your District', search_url(:subdomain => false)

      primary.item :issues, 'Issues', issues_url(params[:session], :subdomain => current_place_subdomain), :class => 'issues primary-nav-issues primary-nav' do |m|
#       if defined?(@issue)
#          m.item :issue, @issue.name, issue_path(@issue), :class => "issue #{@issue.name.parameterize}"
#       end
      end

  #   primary.item :votes, 'Votes', '#', :if => Proc.new { controller.controller_name == 'votes' } do |m|
  #      m.item :bill,  @vote.bill.bill_number, bill_path(@vote.bill.session, @vote.bill), :class => 'bill' do |b|
   #       m.item :vote, 'Vote on ' + @vote.bill.bill_number, vote_path(@vote), :class => "vote #{@vote.outcome_class}", :highlights_on => /\/votes/
   #     end
   #   end
      primary.item :money_trail, 'Campaign Contributions', money_trails_url(:subdomain => current_place_subdomain), :class => 'money_trail primary-nav-money_trail primary-nav' do |m|
  #      if defined?(@industry)
  #        m.item :industry, @industry.name, money_trail_path(@industry)
   #     end
      end

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

  end # controller_name == 'pages' .. else

end
