# frozen_string_literal: true

class WebhookClient
  def self.send(url, payload, headers = {})
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'

    request = Net::HTTP::Post.new(uri.request_uri,
                                  default_headers.merge(headers))
    request.body = payload.to_json

    response = http.request(request)
    log_response(response, url, payload)
    response
  rescue StandardError => e
    Rails.logger.error("WebhookClient failed sending to #{url}: #{e.class} - #{e.message}")
    nil
  end

  def self.default_headers
    {
      'Content-Type' => 'application/json',
    }
  end

  def self.log_response(response, url, payload)
    Rails.logger.info("Webhook sent to #{url}")
    Rails.logger.info("Payload: #{payload}")
    Rails.logger.info("Response: #{response.code} #{response.message}")
  end
end
