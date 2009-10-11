require 'yandex/metrika'
ActionController::Base.send :include, Yandex::Metrika::Mixin
ActionController::Base.send :after_filter, :add_metrika_code
