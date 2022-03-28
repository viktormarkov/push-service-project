# frozen_string_literal: true

class ApplicationContract < Dry::Validation::Contract
  config.messages.backend = :i18n
  config.messages.top_namespace = 'validation'

  register_macro(:email_format) do
    unless value.match? /\A.+@.+\..+\z/
      key.failure(:invalid_format)
    end
  end

  register_macro(:available_city) do
    key.failure(:invalid) if Constants::Cities::ALL.exclude?(value)
  end

  register_macro(:available_role) do
    key.failure(:invalid) if Constants::Roles::ALL.exclude?(value)
  end

  register_macro(:password_length) do
    min_size = Constants::Validations::MIN_PASSWORD_SIZE
    max_size = Constants::Validations::MAX_PASSWORD_SIZE
    key.failure(:min, min_value: min_size) if value.length <= min_size
    key.failure(:max, max_value: max_size) if value.length > max_size
  end
 
  register_macro(:max_string_length) do |macro:|
    max = macro.args[0]
    key.failure(:max, max_value: max) if value.length > max
  end
end