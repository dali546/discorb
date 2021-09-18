require "rspec"

require "discorb"

RSpec.describe "Discorb::Embed" do
  describe "be able to convert to hash" do
    example "with a title" do
      embed = Discorb::Embed.new("Title")
      expect(embed.to_hash).to eq({ title: "Title", type: "rich" })
    end
  end
end
