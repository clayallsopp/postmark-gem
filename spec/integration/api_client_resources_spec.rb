require 'spec_helper'

describe 'Accessing server resources using the API' do

  let(:api_client) {
    Postmark::ApiClient.new(ENV['POSTMARK_API_KEY'], :http_open_timeout => 15)
  }
  let(:recipient) { ENV['POSTMARK_CI_RECIPIENT'] }
  let(:message) {
    {
      :from => "tema+ci@wildbit.com",
      :to => recipient,
      :subject => "Mail::Message object",
      :text_body => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, " \
                    "sed do eiusmod tempor incididunt ut labore et dolore " \
                    "magna aliqua."
    }
  }

  context 'Messages API' do

    def with_retries(max_retries = 20, wait_seconds = 3)
      yield
    rescue => e
      retries = retries ? retries + 1 : 1
      if retries < max_retries
        sleep wait_seconds
        retry
      else
        raise e
      end
    end

    it 'is possible to send a message and access its details via the Messages API' do
      response = api_client.deliver(message)
      message = with_retries {
        api_client.get_message(response[:message_id])
      }
      expect(message[:recipients]).to include(recipient)
    end

    it 'is possible to send a message and dump it via the Messages API' do
      response = api_client.deliver(message)
      dump = with_retries {
        api_client.dump_message(response[:message_id])
      }
      expect(dump[:body]).to include('Mail::Message object')
    end

    it 'is possible to send a message and find it via the Messages API' do
      response = api_client.deliver(message)
      expect {
        with_retries {
          messages = api_client.get_messages(:recipient => recipient,
                                  :fromemail => message[:from],
                                  :subject => message[:subject])
          unless messages.map { |m| m[:message_id] }.include?(response[:message_id])
            raise 'Message not found'
          end
        }
      }.not_to raise_error
    end

  end

end