# frozen_string_literal: true

require 'test_helper'

module Admin
  class LangugesControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in users(:serhat)
      @language = languages(:turkce)
      @form_params = %w[name iso]
    end

    test 'should get index' do
      get admin_languages_path
      assert_equal 'index', @controller.action_name
      assert_response :success
      assert_select '#add-button', translate('.index.new_language_link')
    end

    test 'should get new' do
      get new_admin_language_path
      assert_equal 'new', @controller.action_name
      assert_response :success
      assert_select '.simple_form' do
        @form_params.each do |param|
          assert_select "#language_#{param}"
        end
      end
    end

    test 'should create language' do
      assert_difference('Language.count') do
        post admin_languages_path, params: {
          language: {
            name: 'Test language', iso: 'TLC'
          }
        }
      end

      assert_equal 'create', @controller.action_name

      language = Language.last

      assert_equal 'Test Language', language.name
      assert_equal 'TLC', language.iso
      assert_redirected_to admin_languages_path
      assert_equal translate('.create.success'), flash[:notice]
    end

    test 'should get edit' do
      get edit_admin_language_path(@language)

      assert_equal 'edit', @controller.action_name
      assert_response :success
      assert_select '.simple_form' do
        @form_params.each do |param|
          assert_select "#language_#{param}"
        end
      end
    end

    test 'should update language' do
      language = Language.last
      patch admin_language_path(language), params: {
        language: {
          name: 'Test language Update', iso: 'TLU'
        }
      }

      assert_equal 'update', @controller.action_name

      language.reload

      assert_equal 'Test Language Update', language.name
      assert_equal 'TLU', language.iso
      assert_redirected_to admin_languages_path
      assert_equal translate('.update.success'), flash[:notice]
    end

    test 'should destroy language' do
      assert_difference('Language.count', -1) do
        delete admin_language_path(languages(:language_to_delete))
      end

      assert_equal 'destroy', @controller.action_name
      assert_redirected_to admin_languages_path
      assert_equal translate('.destroy.success'), flash[:notice]
    end

    private

    def translate(key)
      t("admin.languages#{key}")
    end
  end
end
