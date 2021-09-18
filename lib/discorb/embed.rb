# frozen_string_literal: true

module Discorb
  #
  # Represents an embed of discord.
  #
  class Embed
    # @return [String, nil] The title of embed.
    attr_accessor :title
    # @return [String, nil] The description of embed.
    attr_accessor :description
    # @return [String, nil] The url of embed.
    attr_accessor :url
    # @return [Time, nil] The timestamp of embed.
    attr_accessor :timestamp
    # @return [Discorb::Color, nil] The color of embed.
    attr_accessor :color
    # @return [Array<Discorb::Embed::Field>] The fields of embed.
    attr_accessor :fields
    # @return [Symbol] The type of embed.
    attr_reader :type
    attr_reader :image, :thumbnail, :author, :footer

    # @!attribute [rw] image
    #   @return [Discorb::Embed::Image] The image of embed.
    # @!attribute [rw] thumbnail
    #   @return [Discorb::Embed::Thumbnail] The thumbnail of embed.
    # @!attribute [rw] author
    #   @return [Discorb::Embed::Author] The author field of embed.
    # @!attribute [rw] footer
    #  @return [Discorb::Embed::Footer] The footer of embed.

    #
    # Initialize a new Embed object.
    #
    # @param [String] title The title of embed.
    # @param [String] description The description of embed.
    # @param [Discorb::Color] color The color of embed.
    # @param [String] url The url of embed.
    # @param [Time] timestamp The timestamp of embed.
    # @param [Discorb::Embed::Author] author The author field of embed.
    # @param [Array<Discorb::Embed::Field>] fields The fields of embed.
    # @param [Discorb::Embed::Footer] footer The footer of embed.
    # @param [Discorb::Embed::Image, String] image The image of embed.
    # @param [Discorb::Embed::Thumbnail, String] thumbnail The thumbnail of embed.
    #
    def initialize(title = nil, description = nil, color: nil, url: nil, timestamp: nil, author: nil,
                                                   fields: nil, footer: nil, image: nil, thumbnail: nil, data: nil)
      if data.nil?
        @title = title
        @description = description
        @url = url
        @timestamp = timestamp
        @color = color
        @author = author
        @fields = fields || []
        @footer = footer
        @image = image && (image.is_a?(String) ? Image.new(image) : image)
        @thumbnail = thumbnail && (thumbnail.is_a?(String) ? Thumbnail.new(thumbnail) : thumbnail)
        @type = "rich"
      else
        @title = data[:title]
        @description = data[:description]
        @url = data[:url]
        @timestamp = data[:timestamp] && Time.iso8601(data[:timestamp])
        @type = data[:type]
        @color = data[:color] && Color.new(data[:color])
        @footer = data[:footer] && Footer.new(data[:footer][:text], icon: data[:footer][:icon_url])
        @author = if data[:author]
            Author.new(data[:author][:name], icon: data[:author][:icon_url],
                                             url: data[:author][:url])
          end
        @thumbnail = data[:thumbnail] && Thumbnail.new(data[:thumbnail])
        @image = data[:image] && Image.new(data[:image])
        @video = data[:video] && Video.new(data[:video])
        @provider = data[:provider] && Provider.new(data[:provider])
        @fields = data[:fields] ? data[:fields].map { |f| Field.new(f[:name], f[:value], inline: f[:inline]) } : []
      end
    end

    def image=(value)
      @image = (value.respond_to?(:to_s)) ? Image.new(value) : value
    end

    def thumbnail=(value)
      @thumbnail = (value.respond_to?(:to_s)) ? Thumbnail.new(value) : value
    end

    def author=(value)
      @author = (value.respond_to?(:to_s)) ? Author.new(value) : value
    end

    def footer=(value)
      @footer = (value.respond_to?(:to_s)) ? Footer.new(value) : value
    end

    #
    # Convert embed to hash.
    #
    # @see https://discord.com/developers/docs/resources/channel#embed-object-embed-structure Offical Discord API Docs
    # @return [Hash] Converted embed.
    #
    def to_hash
      ret = { type: "rich" }
      ret[:title] = @title if @title
      ret[:description] = @description if @description
      ret[:url] = @url if @url
      ret[:timestamp] = @timestamp&.iso8601 if @timestamp
      ret[:color] = @color&.to_i if @color
      ret[:footer] = @footer&.to_hash if @footer
      ret[:image] = @image&.to_hash if @image
      ret[:thumbnail] = @thumbnail&.to_hash if @thumbnail
      ret[:author] = @author&.to_hash if @author
      ret[:fields] = @fields&.map { |f| f.to_hash } if @fields.any?
      ret
    end

    #
    # Represents an author of embed.
    #
    class Author
      # @return [String] The name of author.
      attr_accessor :name
      # @return [String, nil] The url of author.
      attr_accessor :url
      # @return [String, nil] The icon url of author.
      attr_accessor :icon

      #
      # Initialize a new Author object.
      #
      # @param [String] name The name of author.
      # @param [String] url The url of author.
      # @param [String] icon The icon url of author.
      #
      def initialize(name, url: nil, icon: nil)
        @name = name
        @url = url
        @icon = icon
      end

      #
      # Convert author to hash.
      #
      # @see https://discord.com/developers/docs/resources/channel#embed-object-embed-author-structure Offical Discord API Docs
      # @return [Hash] Converted author.
      #
      def to_hash
        {
          name: @name,
          url: @url,
          icon_url: @icon,
        }
      end
    end

    #
    # Represemts a footer of embed.
    #
    class Footer
      attr_accessor :text, :icon

      #
      # Initialize a new Footer object.
      #
      # @param [String] text The text of footer.
      # @param [String] icon The icon url of footer.
      #
      def initialize(text, icon: nil)
        @text = text
        @icon = icon
      end

      #
      # Convert footer to hash.
      #
      # @see https://discord.com/developers/docs/resources/channel#embed-object-embed-footer-structure Offical Discord API Docs
      # @return [Hash] Converted footer.
      #
      def to_hash
        {
          text: @text,
          icon_url: @icon,
        }
      end
    end

    #
    # Represents a field of embed.
    #
    class Field
      # @return [String] The name of field.
      attr_accessor :name
      # @return [String] The value of field.
      attr_accessor :value
      # @return [Boolean] Whether the field is inline.
      attr_accessor :inline

      #
      # Initialize a new Field object.
      #
      # @param [String] name The name of field.
      # @param [String] value The value of field.
      # @param [Boolean] inline Whether the field is inline.
      #
      def initialize(name, value, inline: true)
        @name = name
        @value = value
        @inline = inline
      end

      #
      # Convert field to hash.
      #
      # @see https://discord.com/developers/docs/resources/channel#embed-object-embed-field-structure Offical Discord API Docs
      # @return [Hash] Converted field.
      #
      def to_hash
        {
          name: @name,
          value: @value,
          inline: @inline,
        }
      end
    end

    #
    # Represents an image of embed.
    #
    class Image
      # @return [String] The url of image.
      attr_accessor :url
      # @return [String] The proxy url of image.
      # @return [nil] The Image object wasn't created from gateway.
      attr_reader :proxy_url
      # @return [Integer] The height of image.
      # @return [nil] The Image object wasn't created from gateway.
      attr_reader :height
      # @return [Integer] The width of image.
      # @return [nil] The Image object wasn't created from gateway.
      attr_reader :width

      #
      # Initialize a new Image object.
      #
      # @param [String] url URL of image.
      #
      def initialize(url)
        data = url
        if data.is_a? String
          @url = data
        else
          @url = data[:url]
          @proxy_url = data[:proxy_url]
          @height = data[:height]
          @width = data[:width]
        end
      end

      #
      # Convert image to hash for sending.
      #
      # @see https://discord.com/developers/docs/resources/channel#embed-object-embed-image-structure Offical Discord API Docs
      # @return [Hash] Converted image.
      #
      def to_hash
        { url: @url }
      end
    end

    #
    # Represents a thumbnail of embed.
    #
    class Thumbnail
      # @return [String] The url of thumbnail.
      attr_accessor :url
      # @return [String] The proxy url of thumbnail.
      # @return [nil] The Thumbnail object wasn't created from gateway.
      attr_reader :proxy_url
      # @return [Integer] The height of thumbnail.
      # @return [nil] The Thumbnail object wasn't created from gateway.
      attr_reader :height
      # @return [Integer] The width of thumbnail.
      # @return [nil] The Thumbnail object wasn't created from gateway.
      attr_reader :width

      #
      # Initialize a new Thumbnail object.
      #
      # @param [String] url URL of thumbnail.
      #
      def initialize(url)
        data = url
        if data.is_a? String
          @url = data
        else
          @url = data[:url]
          @proxy_url = data[:proxy_url]
          @height = data[:height]
          @width = data[:width]
        end
      end

      #
      # Convert thumbnail to hash for sending.
      #
      # @see https://discord.com/developers/docs/resources/channel#embed-object-embed-thumbnail-structure Offical Discord API Docs
      # @return [Hash] Converted thumbnail.
      #
      def to_hash
        { url: @url }
      end
    end

    #
    # Represents a video of embed.
    #
    class Video
      # @return [String] The url of video.
      attr_reader :url
      # @return [String] The proxy url of video.
      attr_reader :proxy_url
      # @return [Integer] The height of video.
      attr_reader :height
      # @return [Integer] The width of video.
      attr_reader :width

      # @!visibility private
      def initialize(data)
        @url = data[:url]
        @proxy_url = data[:proxy_url]
        @height = data[:height]
        @width = data[:width]
      end
    end

    #
    # Represents a provider of embed.
    #
    class Provider
      # @return [String] The name of provider.
      attr_reader :name
      # @return [String] The url of provider.
      attr_reader :url

      # @!visibility private
      def initialize(data)
        @name = data[:name]
        @url = data[:url]
      end
    end
  end
end
