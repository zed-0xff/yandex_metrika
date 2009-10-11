require File.dirname(__FILE__) + '/test_helper.rb'
require 'test/unit'
require 'rubygems'
require 'mocha'
RAILS_ENV = 'test'

class TestMixin
  class MockRequest
    attr_accessor :format
  end
  class MockResponse
    attr_accessor :body
  end

  include Yandex::Metrika::Mixin
  attr_accessor :request, :response

  def initialize
    self.request = MockRequest.new
    self.response = MockResponse.new
  end

  # override the mixin's method
  def metrika_code
    "Sample Code"
  end
end


class MetrikaTest < Test::Unit::TestCase
  def setup
    @ga = Yandex::Metrika.new
    @ga.counter_id = "the tracker id"
  end
  
  def test_createable
    assert_not_nil(@ga)
  end
  
  def test_default_environments
    assert_equal(false, @ga.environments.include?('test'))
    assert_equal(false, @ga.environments.include?('development'))
    assert_equal(true, @ga.environments.include?('production'))
  end
  
  def test_default_formats
    assert_equal(false, @ga.formats.include?(:xml))
    assert_equal(true, @ga.formats.include?(:html))
  end

  def test_defer_load_defaults_to_true
    assert_equal(true, @ga.defer_load)
  end
  
  # test self.enabled
  def test_enabled_requires_counter_id
    Yandex::Metrika.stubs(:counter_id).returns(nil)
    assert_raise(Yandex::Metrika::ConfigurationError) { Yandex::Metrika.enabled?(:html) }
  end
  
  def test_enabled_returns_false_if_current_environment_not_enabled
    Yandex::Metrika.stubs(:environments).returns(['production'])
    assert_equal(false, Yandex::Metrika.enabled?(:html))
  end
  
  def test_enabled_with_default_format
    Yandex::Metrika.stubs(:environments).returns(['test'])
    assert_equal(true, Yandex::Metrika.enabled?(:html))
  end
  
  def test_enabled_with_not_included_format
    Yandex::Metrika.stubs(:environments).returns(['test'])
    assert_equal(false, Yandex::Metrika.enabled?(:xml))
  end
  
  def test_enabled_with_added_format
    Yandex::Metrika.stubs(:environments).returns(['test'])
    Yandex::Metrika.stubs(:formats).returns([:xml])
    assert_equal(true, Yandex::Metrika.enabled?(:xml))
  end

  # Test the before_filter method does what we expect by subsituting the body tags and inserting
  # some code for us automagically.
  def test_add_metrika_code
    # setup our test mixin
    mixin = TestMixin.new

    # bog standard body tag
    Yandex::Metrika.defer_load = false
    mixin.response.body = "<body><p>some text</p></body>"
    mixin.add_metrika_code
    assert_equal mixin.response.body, '<body>Sample Code<p>some text</p></body>'

    Yandex::Metrika.defer_load = true
    mixin.response.body = "<body><p>some text</p></body>"
    mixin.add_metrika_code
    assert_equal mixin.response.body, '<body><p>some text</p>Sample Code</body>'

    # body tag upper cased (ignoring this is semantically incorrect)
    Yandex::Metrika.defer_load = false
    mixin.response.body = "<BODY><p>some text</p></BODY>"
    mixin.add_metrika_code
    assert_equal mixin.response.body, '<BODY>Sample Code<p>some text</p></BODY>'

    Yandex::Metrika.defer_load = true
    mixin.response.body = "<BODY><p>some text</p></BODY>"
    mixin.add_metrika_code
    assert_equal mixin.response.body, '<BODY><p>some text</p>Sample Code</body>'

    # body tag has additional attributes
    Yandex::Metrika.defer_load = false
    mixin.response.body = '<body style="background-color:red"><p>some text</p></body>'
    mixin.add_metrika_code
    assert_equal mixin.response.body, '<body style="background-color:red">Sample Code<p>some text</p></body>'

    Yandex::Metrika.defer_load = true
    mixin.response.body = '<body style="background-color:red"><p>some text</p></body>'
    mixin.add_metrika_code
    assert_equal mixin.response.body, '<body style="background-color:red"><p>some text</p>Sample Code</body>'
  end

end
