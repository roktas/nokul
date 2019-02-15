# frozen_string_literal: true

require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  include AssociationTestModule
  include ValidationTestModule

  test 'type column does not refer to STI' do
    assert_empty Identity.inheritance_column
  end

  # relations
  belongs_to :district
  belongs_to :user

  # validations: presence
  validates_presence_of :full_address
  validates_presence_of :type

  # validations: uniqueness
  validates_uniqueness_of :type

  # validations: length
  validates_length_of :phone_number
  validates_length_of :full_address

  # enumerations
  test 'addresses can respond to enumerators' do
    assert addresses(:formal).formal?
    assert addresses(:informal).informal?
  end

  # callbacks
  test 'callbacks must titlecase the full_address of an address' do
    addresses(:formal).update!(full_address: 'ABC SOKAK', type: 'informal')
    assert_equal addresses(:formal).full_address, 'Abc Sokak'
  end

  # address_validator
  test 'a user can only have one formal address' do
    formal = addresses(:formal).dup
    assert_not formal.valid?
    assert_not_empty formal.errors[:base]
    assert formal.errors[:base].include?(t('validators.address.max_formal', limit: 1))
  end

  test 'a user can only have one informal address' do
    informal = addresses(:informal).dup
    assert_not informal.valid?
    assert_not_empty informal.errors[:base]
    assert informal.errors[:base].include?(t('validators.address.max_informal', limit: 1))
  end
end
