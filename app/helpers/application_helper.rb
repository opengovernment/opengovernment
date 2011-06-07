module ApplicationHelper

  # Page title
  def title(page_title)
    content_for(:title) { page_title }
  end

  # Javascript hooks -- eg. document ready events. or other page-level
  # javascript that can't be accomplished via rails-ujs.
  # <script> tags should not be passed in with the js.
  def javascript
    hook_for(:js_hook) { raw yield }
  end

  def footer_javascript
    hook_for(:js_footer) { raw yield }
  end

  # A slightly more sophisticated content_for.
  # This method won't attach the same hook twice.
  def hook_for(content_block_name)
    @hooks ||= {}
    @hooks[content_block_name] ||= []
    digest = Digest::MD5.hexdigest(yield)
    unless @hooks[content_block_name].include?(digest)
      @hooks[content_block_name] << digest
      content_for(content_block_name) { yield }
    end
  end

  def track(object)
    if MongoMapper.connected?
      footer_javascript do
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
    # This roughly matches the dimensions used in people.rb
    ops = case size
      when :tiny
        {:width => 30, :height => 30}
      when :thumb
        {:width => 50, :height => 50}
      when :full
        {:width => 90} # Variable height.
      else
        {}
      end

    # Use the 50x50 images for 'tiny'.
    if size == :tiny
      size = :thumb
    end

    if person && person.photo?
      # URI encode because some photos actually have
      # % characters in the names. D'oh!
      image_tag(URI.encode(person.photo.url(size)), ops)
    else
      # No photo.
      image_tag('missing.png', ops)
    end
  end

  
  def embed_disqus(page_id)
    # Universal comment count code
    # If you only want comments counts, call this like so:
    #   - embed_disqus([unique-page-id])
    # at the top of the template. Then append #disqus_thread to the
    # href of the link to the comments page.

    # If you want to embed the actual discussion, use:
    #   = embed_disqus([unique-page-id])
    # in the place where you want the discussion to show.
    
    javascript do (%Q{
          var disqus_developer = #{Settings.disqus_developer};
          var disqus_identifier = '#{page_id}';
          var disqus_shortname = '#{ApiKeys.disqus_shortname}';
      })
    end

    footer_javascript do (%q{
      (function () {
        var s = document.createElement('script'); s.async = true;
        s.src = 'http://disqus.com/forums/opengovernment/count.js';
        (document.getElementsByTagName('HEAD')[0] || document.getElementsByTagName('BODY')[0]).appendChild(s);
      }());
      })
    end

    # Universal 
    return %q{<script type="text/javascript">
      (function() {
       var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
       dsq.src = 'http://opengovernment.disqus.com/embed.js';
       (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
      })();
    </script>
    <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript=opengovernment">comments powered by Disqus.</a></noscript>
    <a href="http://disqus.com" class="dsq-brlink">blog comments powered by <span class="logo-disqus">Disqus</span></a>}.html_safe
  end

end
