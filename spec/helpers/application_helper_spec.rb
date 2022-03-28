# frozen_string_literal: true

require "spec_helper"

describe ApplicationHelper, :type => :helper do
  describe "#flash_class" do
    context 'flash type is alert' do
      it 'should return danger class' do
        expect(helper.flash_class('alert')).to eq 'alert-danger'
      end
    end
    context 'flash type is notice' do
      it 'should return success class' do
        expect(helper.flash_class('notice')).to eq 'alert-success'
      end
    end
  end

  describe '#error_from_hash' do
    context 'with empty hash' do
      it 'should return empty string' do
        expect(helper.error_from_hash(nil)).to eq ''
      end
    end

    context 'with errors' do
      let(:errors_hash) do
        {
          password: ['is_empty'],
          email: ['is empty, already exists']
        }
      end

      it 'should return error message string' do
        expect(helper.error_from_hash(errors_hash))
        .to eq 'Password: is_empty. Email: is empty, already exists'
      end
    end

    context 'complex error' do
      let(:errors_hash) do
        {
          message: {
            password: ['is_empty'],
            email: ['is empty, already exists']
          },
          data: []
        }
      end

      it 'should return error message string' do
        expect(helper.error_from_hash(errors_hash))
        .to eq 'Password: is_empty. Email: is empty, already exists'
      end
    end
  end

  describe '#error_from_array' do
    context 'with empty array' do
      it 'should return empty string' do
        expect(helper.error_from_array(nil)).to eq ''
      end
    end

    context 'with errors' do
      let(:errors_array) { ['is empty', 'already exists'] }

      it 'should return error message string' do
        expect(helper.error_from_array(errors_array)).to eq 'is empty. already exists'
      end

      context 'with comma seprator' do
        it 'should return error message string' do
          expect(helper.error_from_array(errors_array, separator: ', ')).to eq 'is empty, already exists'
        end
      end
    end
  end
end