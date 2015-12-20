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

    # Resize the image to fit within the specified dimensions while retaining
    # the original aspect ratio in the same way as {#fill}. Unlike {#fill} it
    # will, if necessary, pad the remaining area with the given color, which
    # defaults to transparent where supported by the image format and white
    # otherwise.
    #
    # The resulting image will always be exactly as large as the specified
    # dimensions.
    #
    # By default, the image will be placed in the center but this can be
    # changed via the `gravity` option.
    #
    # @param [MiniMagick::image] img      the image to convert
    # @param [#to_s] width                the width to fill out
    # @param [#to_s] height               the height to fill out
    # @param [string] background          the color to use as a background
    # @param [string] gravity             which part of the image to focus on
    # @yield [MiniMagick::Tool::Mogrify, MiniMagick::Tool::Convert]
    # @return [void]
    # @see http://www.imagemagick.org/script/color.php
    # @see http://www.imagemagick.org/script/command-line-options.php#gravity
    def watermark(img, width, height, background = "transparent", gravity = "Center")
      # We use `convert` to work around GraphicsMagick's absence of "gravity"
      ::MiniMagick::Tool::Convert.new do |cmd|
        yield cmd if block_given?
        cmd.resize "#{width}x#{height}"
        if background == "transparent"
          cmd.background "rgba(255, 255, 255, 0.0)"
        else
          cmd.background background
        end
        cmd.gravity gravity
        cmd.extent "#{width}x#{height}"
        cmd.merge! [img.path, img.path]
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
[:watermark].each do |name|
  Refile.processor(name, Refile::Watermark.new(name))
end
