# frozen_string_literal: true

require 'spec_helper'

if CanCan::ModelAdapters::ActiveRecordAdapter.version_greater_or_equal?('5.0.0')
  describe CanCan::ModelAdapters::ActiveRecord5Adapter do
    context 'with postgresql' do
      before :each do
        connect_db
        ActiveRecord::Migration.verbose = false

        ActiveRecord::Schema.define do
          create_table(:blog_authors) do |t|
            t.string :name, null: false
            t.timestamps null: false
          end

          create_table(:blog_posts) do |t|
            t.references :blog_author
            t.string :title, null: false
            t.timestamps null: false
          end

          create_table(:blog_post_comments) do |t|
            t.references :blog_post
            t.string :body, null: false
            t.timestamps null: false
          end
        end

        unless defined?(BlogAuthor)
          class BlogAuthor < ActiveRecord::Base
            has_many :blog_posts
            has_many :blog_post_comments, through: :blog_posts
          end
        end

        unless defined?(BlogPost)
          class BlogPost < ActiveRecord::Base
            has_many :blog_post_comments
            belongs_to :blog_author

            default_scope -> { order(:title) }
          end
        end

        unless defined?(BlogPostComment)
          class BlogPostComment < ActiveRecord::Base
            belongs_to :blog_post

            default_scope -> { order(created_at: :desc) }
          end
        end
      end

      subject(:ability) { Ability.new(nil) }

      let(:alex) { BlogAuthor.create!(name: 'Alex') }
      let(:josh) { BlogAuthor.create!(name: 'Josh') }

      let(:p1) { josh.blog_posts.create!(title: 'p1') }
      let(:p2) { alex.blog_posts.create!(title: 'p2') }

      let(:p1c1) { p1.blog_post_comments.create!(body: 'p1c1', created_at: Time.new(2019, 8, 25, 1)) }
      let(:p1c2) { p1.blog_post_comments.create!(body: 'p1c2', created_at: Time.new(2019, 8, 25, 2)) }

      let(:p2c1) { p2.blog_post_comments.create!(body: 'p2c1', created_at: Time.new(2019, 8, 25, 3)) }
      let(:p2c2) { p2.blog_post_comments.create!(body: 'p2c2', created_at: Time.new(2019, 8, 25, 4)) }

      context 'when default scope sets an order, and abilities dont have extra checks' do
        before do
          ability.can :read, BlogPost
          ability.can :read, BlogPostComment
        end

        it 'can get accessible records' do
          accessible = BlogPostComment.accessible_by(ability)
          expected_bodies_in_order = [p2c2, p2c1, p1c2, p1c1].map(&:body)
          expect(accessible.map(&:body)).to eq(expected_bodies_in_order)
        end

        it 'can get accessible records from a has_many' do
          accessible = p2.blog_post_comments.accessible_by(ability)
          expected_bodies_in_order = [p2c2, p2c1].map(&:body)
          expect(accessible.map(&:body)).to eq(expected_bodies_in_order)
        end

        it 'can get accessible records from a has_many - other post' do
          accessible = p1.blog_post_comments.accessible_by(ability)
          expected_bodies_in_order = [p1c2, p1c1].map(&:body)
          expect(accessible.map(&:body)).to eq(expected_bodies_in_order)
        end

        it 'can get accessible records from a has_many :through' do
          accessible = alex.blog_post_comments.accessible_by(ability)
          expected_bodies_in_order = [p2c2, p2c1].map(&:body)
          expect(accessible.map(&:body)).to eq(expected_bodies_in_order)
        end

        it 'can get accessible records from a has_many :through - other user' do
          accessible = josh.blog_post_comments.accessible_by(ability)
          expected_bodies_in_order = [p1c2, p1c1].map(&:body)
          expect(accessible.map(&:body)).to eq(expected_bodies_in_order)
        end
      end

      context 'when default scope sets an order, and abilities have extra checks' do
        before do
          ability.can :read, BlogPost
          # this is the only change vs. the above context -- in this context we can *only* see alex's posts
          ability.can :read, BlogPostComment, blog_post: { blog_author_id: alex.id }
        end

        it 'can get accessible records' do
          accessible = BlogPostComment.accessible_by(ability)
          expected_bodies_in_order = [p2c2, p2c1].map(&:body)
          expect(accessible.map(&:body)).to eq(expected_bodies_in_order)
        end

        it 'can get accessible records from a has_many' do
          accessible = p2.blog_post_comments.accessible_by(ability)
          expected_bodies_in_order = [p2c2, p2c1].map(&:body)
          expect(accessible.map(&:body)).to eq(expected_bodies_in_order)
        end

        it 'can get accessible records from a has_many - none returned' do
          accessible = p1.blog_post_comments.accessible_by(ability)
          expected_bodies_in_order = []
          expect(accessible.map(&:body)).to eq(expected_bodies_in_order)
        end

        it 'can get accessible records from a has_many :through' do
          accessible = alex.blog_post_comments.accessible_by(ability)
          expected_bodies_in_order = [p2c2, p2c1].map(&:body)
          expect(accessible.map(&:body)).to eq(expected_bodies_in_order)
        end

        it 'can get accessible records from a has_many :through - none returned' do
          accessible = josh.blog_post_comments.accessible_by(ability)
          expected_bodies_in_order = []
          expect(accessible.map(&:body)).to eq(expected_bodies_in_order)
        end
      end
    end
  end
end
