module SimpleNavigation
  module Renderer
    
    # Renders an ItemContainer as a <div> element and its containing items as <a> elements.
    # It only renders 'selected' elements.
    #
    # By default, the renderer sets the item's key as dom_id for the rendered <a> element unless the config option <tt>autogenerate_item_ids</tt> is set to false.
    # The id can also be explicitely specified by setting the id in the html-options of the 'item' method in the config/navigation.rb file.
    # The ItemContainer's dom_class and dom_id are applied to the surrounding <div> element.
    #
    class Bread < SimpleNavigation::Renderer::Base
      
      def render(item_container)
        a_tags = a_tags(item_container)
        html_safe(a_tags.join(join_with))
      end

      protected

      def a_tags(item_container, level = 0)
        i = 0
        item_container.items.inject([]) do |list, item|
          ops = item.html_options.except(:id)
          if item.selected?
            if i == 0 && level == 0
              ops[:class].concat(' first')
            end
            list << content_tag(:li, link_to(html_safe(content_tag(:span, item.name)), item.url, {:method => item.method}.merge(item.html_options.except(:class, :id))), ops)

            # Recurse if necessary
            list.concat(a_tags(item.sub_navigation, level + 1)) if include_sub_navigation?(item)
            i += 1
          end
          list
        end
      end

      def join_with
        @join_with ||= options[:join_with] || " "
      end
    end
    
  end
end