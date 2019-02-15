# frozen_string_literal: true

require 'test_helper'
require_relative '../concerns/references_resource_test'

class LanguagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @variables = { name: 'Test Language', iso: 'TLC' }
  end

  include ReferenceResourceTest
end
