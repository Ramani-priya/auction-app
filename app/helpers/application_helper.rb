# frozen_string_literal: true

module ApplicationHelper
  def formatted_time(datetime)
    l(datetime, format: :long)
  end
end
