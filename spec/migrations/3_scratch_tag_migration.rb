class ScratchTagMigration < ActiveRecord::Migration
  def up
    create_table :scratch_taggings do |t|
      t.integer  "scratch_tag_id", index: true
      t.integer  "user_id", index: true
    end

    create_table :scratch_tags do |t|
      t.integer :scratch_taggings_count, default: 0, null: false
      t.string :name, null: false, index: true
    end
  end

  def down
    drop_table :scratch_tags
    drop_table :scratch_taggings
  end
end
