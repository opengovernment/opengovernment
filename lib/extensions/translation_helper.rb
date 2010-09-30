module ActionView
  module Helpers
    module TranslationHelper
      def translate_raw(key, options = {})
        translation = I18n.translate(scope_key_by_partial(key), options.merge!(:raise => true))
        raw(translation)
      rescue I18n::MissingTranslationData => e
        keys = I18n.normalize_keys(e.locale, e.key, e.options[:scope])
        content_tag('span', keys.join(', '), :class => 'translation_missing')
      end

      alias :t :translate_raw
    end
  end
end
