# frozen_string_literal: true

class DeleteUserContract < ApplicationContract
  params do
    required(:id).value(:integer)
  end
end