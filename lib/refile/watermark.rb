require "refile"
require "refile/watermark/version"
require "mini_magick"

module Refile
  # Adds watermarking to Refile
  class Watermark
    # @param [Symbol] method        The method to invoke on {#call}
    def initialize(method)
      @method = method
    end

    # Watermarks the image with another image, and also uses the fill processor
    # to resize the initial image
    #
    # The resulting image will always be exactly as large as the specified
    # dimensions.
    #
    # By default, the watermark and original image will be placed in the center but this can be
    # changed via the `gravity` option.
    #
    # @param [MiniMagick::image] img           the background image which will be modified
    # @param [#to_s] width                     the width to fill out
    # @param [#to_s] height                    the height to fill out
    # @param [string] watermark_image_filename the image to use as watermark (file must be in the app/assets/images folder)
    # @param [string] gravity                  which part of the image to focus on and put the watermark on
    # @return [void]
    # @see http://www.imagemagick.org/script/command-line-options.php#gravity
    def fill_watermark_image(img, width, height, watermark_image_filename, gravity = "Center", horizontal_margin = 0, vertical_margin = 0, opacity = 20, logo_gravity = nil)
      Refile::MiniMagick.new(:fill).fill(img, width, height, gravity)

      second_image = ::MiniMagick::Image.new(Rails.root.join('app', 'assets', 'images', watermark_image_filename).to_s)

      result = img.composite(second_image) do |composite|
        composite.compose "Over"    # OverCompositeOp
        composite.geometry "+#{horizontal_margin}+#{vertical_margin}" # copy second_image onto first_image from (horizontal_margin, vertical_margin)
        composite.dissolve "#{opacity},100" # make second_image more or less transparent on top of first image
        composite.gravity (logo_gravity || gravity)
      end
      result.write img.path
    end

    def fit_watermark_image(img, width, height, watermark_image_filename,
      opacity = 20, gravity = "SouthEast")

      Refile::MiniMagick.new(:fit).fit(img, width, height)

      second_image = ::MiniMagick::Image.open(Rails.root.join(
        "app", "assets", "images", watermark_image_filename
      ).to_s)

      watermark_size_ratio = 0.2
      margin_size_ratio = 0.05

      if img.width < img.height
        watermark_size_limit = img.width * watermark_size_ratio
        margin_size = img.width * margin_size_ratio
      else
        watermark_size_limit = img.height * watermark_size_ratio
        margin_size = img.height * margin_size_ratio
      end

      Refile::MiniMagick.new(:fit).fit(second_image,
        watermark_size_limit, watermark_size_limit)

      result = img.composite(second_image) do |composite|
        composite.compose("Over")
        composite.geometry("+#{margin_size}+#{margin_size}")
        composite.dissolve("#{opacity},100")
        composite.gravity(gravity)
      end

      result.write(img.path)
    end

    # Watermarks the image with text, and also uses the fill processor
    # to resize the initial image
    #
    # The resulting image will always be exactly as large as the specified
    # dimensions.
    #
    # By default, the original image will be placed in the center.
    # The watermark will always be on the middle-right.
    #
    # @param [MiniMagick::image] img           the background image which will be modified
    # @param [#to_s] width                     the width to fill out
    # @param [#to_s] height                    the height to fill out
    # @param [string] watermark_image_filename the image to use as watermark (file must be in the app/assets/images folder)
    # @param [string] gravity                  which part of the image to focus on
    # @return [void]
    # @see http://www.imagemagick.org/script/command-line-options.php#gravity
    def fill_watermark_text(img, width, height, text1, text2, text3, gravity = "Center")
      Refile::MiniMagick.new(:fill).fill(img, width, height, gravity)

      boxheight = (height.to_i*0.8).round(2) - (height.to_i*0.4).round(2)
      fontsize_sm = (boxheight / 6) # 1pt = 1px at default pixel density (72 ppi)
      fontsize_lg = (boxheight / 4)

      img.combine_options do |c|
        c.draw "fill #cccccc fill-opacity 0.4 roundrectangle #{(width.to_i*0.6).round(2)},#{(height.to_i*0.4).round(2)} #{width},#{(height.to_i*0.8).round(2)} 10,10"
        c.pointsize fontsize_sm
        c.draw "fill #ffffff fill-opacity 1 text #{(width.to_i*0.6+10).round(2)},#{(height.to_i*0.8-(boxheight/8)-fontsize_lg-fontsize_sm).round(2)} \"#{text1}\""
        c.draw "fill #ffffff fill-opacity 1 text #{(width.to_i*0.6+10).round(2)},#{(height.to_i*0.8-(boxheight/8)-fontsize_lg).round(2)} \"#{text2}\""
        c.pointsize fontsize_lg
        c.draw "fill #000000 fill-opacity 1 text #{(width.to_i*0.6+10).round(2)},#{(height.to_i*0.8-(boxheight/8)).round(2)} \"#{text3}\""
      end
    end

    # Process the given file. The file will be processed via one of the
    # instance methods of this class, depending on the `method` argument passed
    # to the constructor on initialization.
    #
    # If the format is given it will convert the image to the given file format.
    #
    # @param [Tempfile] file        the file to manipulate
    # @param [String] format        the file format to convert to
    # @return [File]                the processed file
    def call(file, *args, format: nil, &block)
      img = ::MiniMagick::Image.new(file.path)
      img.format(format.to_s.downcase, nil) if format
      send(@method, img, *args, &block)

      ::File.open(img.path, "rb")
    end
  end
end

# Register Watermark as a valid Refile processor
[:fill_watermark_image, :fit_watermark_image, :fill_watermark_text].each do |name|
  Refile.processor(name, Refile::Watermark.new(name))
end
