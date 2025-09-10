# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'from@bidsphere.com'
  layout 'mailer'
end
