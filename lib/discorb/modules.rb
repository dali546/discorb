# frozen_string_literal: true

module Discorb
  #
  # Module for sending and reading messages.
  #
  module Messageable
    #
    # Post a message to the channel.
    # @macro async
    # @macro http
    #
    # @param [String] content The message content.
    # @param [Boolean] tts Whether the message is tts.
    # @param [Discorb::Embed] embed The embed to send.
    # @param [Array<Discorb::Embed>] embeds The embeds to send.
    # @param [Discorb::AllowedMentions] allowed_mentions The allowed mentions.
    # @param [Discorb::Message, Discorb::Message::Reference] reference The message to reply to.
    # @param [Array<Discorb::Component>, Array<Array<Discorb::Component>>] components The components to send.
    # @param [Discorb::File] file The file to send.
    # @param [Array<Discorb::File>] files The files to send.
    #
    # @return [Async::Task<Discorb::Message>] The message sent.
    #
    def post(content = nil, tts: false, embed: nil, embeds: nil, allowed_mentions: nil,
                            reference: nil, components: nil, file: nil, files: nil)
      Async do
        payload = {}
        payload[:content] = content if content
        payload[:tts] = tts
        tmp_embed = if embed
            [embed]
          elsif embeds
            embeds
          end
        payload[:embeds] = tmp_embed.map(&:to_hash) if tmp_embed
        payload[:allowed_mentions] =
          allowed_mentions ? allowed_mentions.to_hash(@client.allowed_mentions) : @client.allowed_mentions.to_hash
        payload[:message_reference] = reference.to_reference if reference
        payload[:components] = Component.to_payload(components) if components
        files = [file] if file
        if files
          seperator, payload = HTTP.multipart(payload, files)
          headers = { "content-type" => "multipart/form-data; boundary=#{seperator}" }
        else
          headers = {}
        end
        _resp, data = @client.http.post("/channels/#{channel_id.wait}/messages", payload, headers: headers).wait
        Message.new(@client, data.merge({ guild_id: @guild_id.to_s }))
      end
    end

    alias send_message post

    #
    # Edit a message.
    # @macro async
    # @macro http
    #
    # @param [#to_s] message_id The message id.
    # @param [String] content The message content.
    # @param [Discorb::Embed] embed The embed to send.
    # @param [Array<Discorb::Embed>] embeds The embeds to send.
    # @param [Discorb::AllowedMentions] allowed_mentions The allowed mentions.
    # @param [Array<Discorb::Component>, Array<Array<Discorb::Component>>] components The components to send.
    # @param [Boolean] supress Whether to supress embeds.
    #
    def edit_message(message_id, content = nil, embed: nil, embeds: nil, allowed_mentions: nil,
                                                components: nil, supress: nil)
      Async do
        payload = {}
        payload[:content] = content if content
        tmp_embed = if embed
            [embed]
          elsif embeds
            embeds
          end
        payload[:embeds] = tmp_embed.map(&:to_hash) if tmp_embed
        payload[:allowed_mentions] =
          allowed_mentions ? allowed_mentions.to_hash(@client.allowed_mentions) : @client.allowed_mentions.to_hash
        payload[:components] = Component.to_payload(components) if components
        payload[:flags] = (supress ? 1 << 2 : 0) unless supress.nil?
        @client.http.patch("/channels/#{channel_id.wait}/messages/#{message_id}", payload).wait
      end
    end

    #
    # Delete a message.
    # @macro async
    # @macro http
    #
    # @param [#to_s] message_id The message id.
    # @param [String] reason The reason for deleting the message.
    #
    def delete_message!(message_id, reason: nil)
      Async do
        @client.http.delete("/channels/#{channel_id.wait}/messages/#{message_id}", audit_log_reason: reason).wait
      end
    end

    alias destroy_message! delete_message!

    #
    # Fetch a message from ID.
    # @macro async
    # @macro http
    #
    # @param [Discorb::Snowflake] id The ID of the message.
    #
    # @return [Async::Task<Discorb::Message>] The message.
    # @raise [Discorb::NotFoundError] If the message is not found.
    #
    def fetch_message(id)
      Async do
        _resp, data = @client.http.get("/channels/#{channel_id.wait}/messages/#{id}").wait
        Message.new(@client, data.merge({ guild_id: @guild_id.to_s }))
      end
    end

    #
    # Fetch a message history.
    # @macro async
    # @macro http
    #
    # @param [Integer] limit The number of messages to fetch.
    # @param [Discorb::Snowflake] before The ID of the message to fetch before.
    # @param [Discorb::Snowflake] after The ID of the message to fetch after.
    # @param [Discorb::Snowflake] around The ID of the message to fetch around.
    #
    # @return [Async::Task<Array<Discorb::Message>>] The messages.
    #
    def fetch_messages(limit = 50, before: nil, after: nil, around: nil)
      Async do
        params = {
          limit: limit,
          before: Discorb::Utils.try(after, :id),
          after: Discorb::Utils.try(around, :id),
          around: Discorb::Utils.try(before, :id),
        }.filter { |_k, v| !v.nil? }.to_h
        _resp, messages = @client.http.get("/channels/#{channel_id.wait}/messages?#{URI.encode_www_form(params)}").wait
        messages.map { |m| Message.new(@client, m.merge({ guild_id: @guild_id.to_s })) }
      end
    end

    #
    # Fetch the pinned messages in the channel.
    # @macro async
    # @macro http
    #
    # @return [Async::Task<Array<Discorb::Message>>] The pinned messages in the channel.
    #
    def fetch_pins
      Async do
        _resp, data = @client.http.get("/channels/#{channel_id.wait}/pins").wait
        data.map { |pin| Message.new(@client, pin) }
      end
    end

    #
    # Pin a message in the channel.
    # @macro async
    # @macro http
    #
    # @param [Discorb::Message] message The message to pin.
    # @param [String] reason The reason of pinning the message.
    #
    def pin_message(message, reason: nil)
      Async do
        @client.http.put("/channels/#{channel_id.wait}/pins/#{message.id}", {}, audit_log_reason: reason).wait
      end
    end

    #
    # Unpin a message in the channel.
    # @macro async
    # @macro http
    #
    # @param [Discorb::Message] message The message to unpin.
    # @param [String] reason The reason of unpinning the message.
    #
    def unpin_message(message, reason: nil)
      Async do
        @client.http.delete("/channels/#{channel_id.wait}/pins/#{message.id}", audit_log_reason: reason).wait
      end
    end

    #
    # Trigger the typing indicator in the channel.
    # @macro async
    # @macro http
    #
    # If block is given, trigger typing indicator during executing block.
    # @example
    #   channel.typing do
    #     channel.post("Waiting for 60 seconds...")
    #     sleep 60
    #     channel.post("Done!")
    #   end
    #
    def typing
      if block_given?
        begin
          post_task = Async do
            loop do
              @client.http.post("/channels/#{@id}/typing", {})
              sleep(5)
            end
          end
          yield
        ensure
          post_task.stop
        end
      else
        Async do |task|
          @client.http.post("/channels/#{@id}/typing", {})
        end
      end
    end
  end

  #
  # Module for connecting to a voice channel.
  # This will be discord-voice gem.
  #
  module Connectable
    def connect
      raise NotImplementedError, "This method is implemented by discord-voice gem."
    end
  end
end
