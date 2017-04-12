# Refile::Watermark

Warning: this is basically sample code, it's not on RubyGems and the code isn't very good, though it should work.

A Refile image processor to enable creation of watermarks

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'refile-watermark'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install refile-watermark

## Usage

### Fill watermark image method

`fill_watermark_image(img, width, height, watermark_image_filename, gravity = "Center", horizontal_margin = 0, vertical_margin = 0, opacity = 100)`

Just like any other Refile processor, for example:

    <%= image_tag attachment_url(@user, :profile_image, :fill_watermark_image, 300, 300, "watermark.jpg", "SouthEast", 10, 10, 50) %>

    <%= image_tag attachment_url(@user, :profile_image, :fill_watermark_text, 300, 300, "My Watermark", format: "jpg") %>

## Contributing

1. Fork it ( https://github.com/[my-github-username]/refile-watermark/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
