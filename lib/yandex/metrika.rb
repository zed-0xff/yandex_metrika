require 'active_support'
require 'action_pack'
require 'action_view'

module Yandex # :nodoc:
  class Metrika

    # This module gets mixed in to ActionController::Base
    module Mixin
      # The javascript code to enable Yandex.Metrika on the current page.
      # Normally you won't need to call this directly; the +add_yandex_metrika_code+
      # after filter will insert it for you.
      def metrika_code
        Metrika.code if Metrika.enabled?(request.format)
      end

      # An after_filter to automatically add the metrika code.
      def add_yandex_metrika_code
        response.body =
          if Metrika.defer_load
            response.body.sub /<\/[bB][oO][dD][yY]>/, "#{metrika_code}</body>"
          else
            response.body.sub /(<[bB][oO][dD][yY][^>]*>)/, "\\1#{metrika_code}"
          end
      end
    end

    class ConfigurationError < StandardError #:nodoc:
      DEFAULT_MESSAGE = "Yandex::Metrika.counter_id is not set in config/initializers/yandex_metrika.rb"

      def initialize(message = nil)
        super(message || DEFAULT_MESSAGE)
      end
    end

    @@counter_id = nil
    ##
    # :singleton-method:
    # Specify the Yandex.Metrika COUNTER_ID for this web site. This can be found
    # as the value of "new Ya.Metrika(123456)", where 123456 is the actual ID.
    cattr_accessor :counter_id

    @@environments = ['production']
    ##
    # :singleton-method:
    # The environments in which to enable the Yandex.Metrika code. Defaults
    # to 'production' only. Supply an array of environment names to change this.
    cattr_accessor :environments

    @@formats = [:html, :all]
    ##
    # :singleton-method:
    # The request formats where tracking code should be added. Defaults to +[:html, :all]+. The entry for
    # +:all+ is necessary to make Yandex recognize that tracking is installed on a
    # site; it is not the same as responding to all requests. Supply an array
    # of formats to change this.
    cattr_accessor :formats

    @@defer_load = true
    ##
    # :singleton-method:
    # Set this to true (the default) if you want to load the Metrika javascript at
    # the bottom of page. Set this to false if you want to load the Metrika
    # javascript at the top of the page. The page will render faster if you set this to
    # true.
    cattr_accessor :defer_load

    # Return true if the Yandex.Metrika system is enabled and configured
    # correctly for the specified format
    def self.enabled?(format)
      raise ConfigurationError if counter_id.blank?
      environments.include?(Rails.env) && formats.include?(format.to_sym)
    end

    # Construct the javascript code to be inserted on the calling page.
    def self.code
      <<-EOHTML
        <!-- Yandex.Metrika -->
        <script src="//mc.yandex.ru/resource/watch.js" type="text/javascript"></script>
        <script type="text/javascript">
        try { var yaCounter#{counter_id} = new Ya.Metrika(#{counter_id}); } catch(e){}
        </script>
        <noscript><div style="position: absolute;"><img src="//mc.yandex.ru/watch/#{counter_id}" alt="" /></div></noscript>
        <!-- /Yandex.Metrika -->
      EOHTML
    end
  end
end
