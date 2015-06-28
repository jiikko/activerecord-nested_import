require 'spec_helper'

describe ActiveRecord::NestedImport do
  it 'has a version number' do
    expect(ActiveRecord::NestedImport::VERSION).not_to be nil
  end

  describe '#nested_import' do
    let(:words) { %w(ジャバ ゆうお おお ジャバ うおおお　やま やば) }

    context 'with 0 record' do
      it 'be success' do
        attrs = words.map { |x| { name: x } }
        user = User.create
        user.nested_import(
          :tags,
          words.map { |x| { name: x } }
        )
        expect(user.tags.count).to eq 5
        expect(user.taggings.count).to eq 5
      end
    end

    context 'with existing records' do
      it 'be success' do
        # TODO
      end
    end
  end
end
