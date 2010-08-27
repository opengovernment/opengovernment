require 'trackable'

module ActsAsTaggableOn
  class Tag < ::ActiveRecord::Base
    include Trackable

    def to_param
      name.parameterize
    end

    def self.find_by_param(param, ops = {})
      find_by_name(param.titleize.downcase, ops)
    end
  end
  module TagsHelper
    # See the README for an example using tag_cloud.
    def tag_cloud(tags, classes)
      tags = tags.all if tags.respond_to?(:all)

      return [] if tags.empty?

      max_count = tags.sort_by(&:count).last.count.to_f

      tags.each do |tag|
        index = ((tag.count / max_count) * (classes.size - 1)).round rescue -1
        yield tag, classes[index]
      end
    end
  end
end
