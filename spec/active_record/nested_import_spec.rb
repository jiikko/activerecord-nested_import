require 'spec_helper'

describe ActiveRecord::NestedImport do
  it 'has a version number' do
    expect(ActiveRecord::NestedImport::VERSION).not_to be nil
  end

  describe '#nested_import' do
    let(:words) { %w(ジャバ ゆうお おお ジャバ うおおお　やま やば) }

    describe 'acts_as_taggable_on' do
      context 'with empty record' do
        it 'has 5 records' do
          user = User.create
          user.nested_import(
            :tags,
            words.map { |x| { name: x } }
          )
          expect(user.tags.count).to eq 5
          expect(user.taggings.count).to eq 5
        end
      end
      context 'with exist tags records' do
        it 'has 5 records' do
          User.create.nested_import(
            :tags,
            words.map { |x| { name: x } }
          )
          user = User.create
          user.nested_import(
            :tags,
            words.map { |x| { name: x } }
          )
          expect(user.tags.count).to eq 5
          expect(user.taggings.count).to eq 5
        end
      end

      context 'with exist my tags records' do
        it 'has 5 records' do
          user = User.create
          user.nested_import(
            :tags,
            words.map { |x| { name: x } }
          )
          user.nested_import(
            :tags,
            words.map { |x| { name: x } }
          )
          expect(user.tags.count).to eq 5
          expect(user.taggings.count).to eq 5
        end
      end
    end

    describe 'scratch' do
      context 'with empty record' do
        it 'has 5 records' do
          user = User.create
          user.nested_import(
            :scratch_tags,
            words.map { |x| { name: x } }
          )
          expect(user.scratch_tags.count).to eq 5
          expect(user.scratch_taggings.count).to eq 5
        end
      end
      context 'with exist tags records' do
        it 'has 5 records' do
          User.create.nested_import(
            :scratch_tags,
            words.map { |x| { name: x } }
          )
          user = User.create
          user.nested_import(
            :scratch_tags,
            words.map { |x| { name: x } }
          )
          expect(user.scratch_tags.count).to eq 5
          expect(user.scratch_taggings.count).to eq 5
        end
      end

      context 'with exist my tags records' do
        it 'has 5 records' do
          user = User.create
          user.nested_import(
            :scratch_tags,
            words.map { |x| { name: x } }
          )
          user.nested_import(
            :scratch_tags,
            words.map { |x| { name: x } }
          )
          expect(user.scratch_tags.count).to eq 5
          expect(user.scratch_taggings.count).to eq 5
        end
      end
    end
  end
end
