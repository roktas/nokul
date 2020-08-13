# frozen_string_literal: true

require 'test_helper'

class VerificationServiceTest < ActiveSupport::TestCase
  setup do
    @v = verifications(:one)

    @verification =
      VerificationService.new(
        mobile_phone: @v.mobile_phone
      )
  end
  test 'verification code should be changed on every request' do
    assert_not_equal @verification.code, @v.code
  end

  test 'should not send if sms limit exceeded' do
    REDIS.set("sms_count_#{@v.mobile_phone}", 5)
    assert_not @verification.can_be_sent?
  end
end
