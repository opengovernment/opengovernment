module ApplicationHelper

  # Page title
  def title(page_title)
    content_for(:title) { page_title }
  end

  # Javascript hooks -- eg. document ready events. or other page-level
  # javascript that can't be accomplished via rails-ujs.
  # <script> tags should not be passed in with the js.
  def javascript
    content_for(:js_hook) { yield }
  end

  def track(object)
    if MongoMapper.connected?
      javascript do
        %Q|
            $(document).ready(function() {
              Tracker.req.object_id = #{object.id};
              Tracker.req.object_type = '#{object.class}';
              Tracker.track();
            });
          |
      end
    end
  end

  def photo_for(person, size = :full)
    ops = case size
      when :thumb
        {:width => 50, :height => 50}
      else
        {:width => 110, :height => 110}
          end

    if person.photo?
      # The local photo
      image_tag(person.photo.url(size), ops)
    elsif person.photo_url(size)
      # The remote photo, as a backup
      image_tag(person.photo_url(size), ops)
    else
      # No photo.
      image_tag('missing.png', ops)
    end
  end
end
