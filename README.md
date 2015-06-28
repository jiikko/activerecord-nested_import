# ActiveRecord::NestedImport

activerecord-nested_import is activerecord-import wrapper.

## Requirement

activerecord-import

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-nested_import'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-nested_import

## Usage

TODO
```ruby
post = Post.find(1)
tag_attrs = [{ name: :human }, { name: :life }, { name: :animal }]
post.nested_import(:tags, tag_attrs)
post.tags.map(&:name) # => ['human', 'life', 'animal']
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/activerecord-nested_import/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
