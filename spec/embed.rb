require "rspec"

require "discorb"

RSpec.describe "Discorb::Embed" do
  describe "be able to convert to hash" do
    it "success with title" do
      embed = Discorb::Embed.new("Title")
      expect(embed.to_hash).to eq(
        {
          title: "Title",
          type: "rich",
        }
      )
    end

    it "success with title and description" do
      embed = Discorb::Embed.new("Title", "Description")
      expect(embed.to_hash).to eq(
        {
          title: "Title",
          description: "Description",
          type: "rich",
        }
      )
    end

    it "success with title, description and url" do
      embed = Discorb::Embed.new("Title", "Description", url: "https://example.com/")
      expect(embed.to_hash).to eq(
        {
          title: "Title",
          description: "Description",
          url: "https://example.com/",
          type: "rich",
        }
      )
    end

    it "success with title, description, url and color" do
      embed = Discorb::Embed.new(
        "Title", "Description",
        url: "https://example.com/",
        color: Discorb::Color.from_hex("#FF0000"),
      )
      expect(embed.to_hash).to eq(
        {
          title: "Title",
          description: "Description",
          url: "https://example.com/",
          color: 16711680,
          type: "rich",
        }
      )
    end

    it "success with title, description, url, color and author" do
      embed = Discorb::Embed.new(
        "Title", "Description",
        url: "https://example.com/",
        color: Discorb::Color.from_hex("#FF0000"),
        author: Discorb::Embed::Author.new("Author"),
      )
      expect(embed.to_hash).to eq(
        {
          title: "Title",
          description: "Description",
          url: "https://example.com/",
          color: 16711680,
          author: {
            icon_url: nil,
            name: "Author",
            url: nil,
          },
          type: "rich",
        }
      )
    end

    describe "will be able to convert from string to object" do
      it "success in author" do
        embed = Discorb::Embed.new
        embed.author = "Author"
        expect(embed.author).to be_a(Discorb::Embed::Author)
        expect(embed.author.to_hash).to eq(
          {
            icon_url: nil,
            name: "Author",
            url: nil,
          }
        )
      end

      it "success in footer" do
        embed = Discorb::Embed.new
        embed.footer = "Footer"
        expect(embed.footer).to be_a(Discorb::Embed::Footer)
        expect(embed.footer.to_hash).to eq(
          {
            text: "Footer",
            icon_url: nil,
          }
        )
      end

      it "success in image" do
        embed = Discorb::Embed.new
        embed.image = "Image"
        expect(embed.image).to be_a(Discorb::Embed::Image)
        expect(embed.image.to_hash).to eq(
          {
            url: "Image",
          }
        )
      end

      it "success in thumbnail" do
        embed = Discorb::Embed.new
        embed.thumbnail = "Thumbnail"
        expect(embed.thumbnail).to be_a(Discorb::Embed::Thumbnail)
        expect(embed.thumbnail.to_hash).to eq(
          {
            url: "Thumbnail",
          }
        )
      end
    end
  end
end
