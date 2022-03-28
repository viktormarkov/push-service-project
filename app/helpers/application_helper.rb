# frozen_string_literal: true

module ApplicationHelper
  def flash_class(type)
    case type
    when 'alert'
      'alert-danger'
    when 'notice'
      'alert-success'
    end
  end

  def error_from_hash(error)
    messages = []
    return error_from_array(messages) if error.blank?
    error_hash = error[:message] || error 
    error_hash.each do |key, errors_array|
      messages << t("custom.errors.keys.#{key}") + ": #{error_from_array(errors_array, separator: ', ')}"
    end
    error_from_array(messages)
  end

  def error_from_array(error_array, separator: '. ')
    return '' if error_array.nil?
    error_array.join(separator)
  end
end
